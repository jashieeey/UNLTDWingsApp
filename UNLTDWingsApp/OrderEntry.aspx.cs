using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using UNLTDWingsApp.Utilities;

namespace UNLTDWingsApp
{
    public partial class OrderEntry : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Staff/Admin only
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Staff", StringComparison.OrdinalIgnoreCase) && !role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            // Table accounts should not use staff order entry
            bool isTable = Session["IsTableAccount"] != null && Session["IsTableAccount"] is bool && (bool)Session["IsTableAccount"]; 
            if (isTable)
            {
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            // Enforce order type rules for staff/admin
            if (Session["CurrentOrderType"] == null)
            {
                Session["CurrentOrderType"] = "Walk-in";
            }

            if (!IsPostBack)
            {
                 string orderType = Session["CurrentOrderType"] != null ? Session["CurrentOrderType"].ToString() : "Walk-in";
               lblOrderType.Text = orderType;

 var pnlDineInLocal = FindControl("pnlDineIn") as System.Web.UI.WebControls.Panel;
   var pnlDeliveryFieldsLocal = FindControl("pnlDeliveryFields") as System.Web.UI.WebControls.Panel;
    var pnlCustomerLocal = FindControl("pnlCustomer") as System.Web.UI.WebControls.Panel;
              if (pnlDineInLocal != null) pnlDineInLocal.Visible = orderType == "Dine-in";
    if (pnlDeliveryFieldsLocal != null) pnlDeliveryFieldsLocal.Visible = orderType == "Delivery";
                if (pnlCustomerLocal != null) pnlCustomerLocal.Visible = orderType != "Dine-in";

                LoadMenu();
                InitializeCart();
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void LoadMenu()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Use PHP instead of peso symbol for compatibility
                    string query = "SELECT ItemID, CONCAT(ItemName, ' - PHP ', FORMAT(Price, 'N2')) AS DisplayText, Price FROM Menu_Item WHERE IsAvailable = 1 ORDER BY ItemCategory, ItemName";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();
                        ddlMenu.DataSource = reader;
                        ddlMenu.DataTextField = "DisplayText";
                        ddlMenu.DataValueField = "ItemID";
                        ddlMenu.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMenuError.Text = "Failed to load menu: " + ex.Message;
            }
        }

        private void InitializeCart()
        {
            // Create a temporary table in memory to hold cart items before checkout
            DataTable dtCart = new DataTable();
            dtCart.Columns.Add("ItemID", typeof(int));
            dtCart.Columns.Add("ItemName", typeof(string));
            dtCart.Columns.Add("Price", typeof(decimal));
            dtCart.Columns.Add("Quantity", typeof(int));
            dtCart.Columns.Add("Subtotal", typeof(decimal));

            ViewState["Cart"] = dtCart;
            BindCart();
        }

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            lblMenuError.Text = "";
            if (ddlMenu.SelectedIndex == -1 || string.IsNullOrEmpty(txtQuantity.Text)) return;

            int itemId = int.Parse(ddlMenu.SelectedValue);
            string itemName = ddlMenu.SelectedItem.Text.Split('-')[0].Trim();
            int quantity;

            if (!int.TryParse(txtQuantity.Text, out quantity) || quantity < 1)
            {
                lblMenuError.Text = "Please enter a valid quantity.";
                return;
            }

            // Fetch price from DB to ensure it's accurate
            decimal price = 0;
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT Price FROM Menu_Item WHERE ItemID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", itemId);
                        conn.Open();
                        price = Convert.ToDecimal(cmd.ExecuteScalar());
                    }
                }
            }
            catch (Exception ex)
            {
                lblMenuError.Text = "Error: " + ex.Message;
                return;
            }

            decimal subtotal = price * quantity;

            // Add to ViewState Cart
            DataTable dtCart = (DataTable)ViewState["Cart"];
            
            // Check if item already exists
            DataRow[] existingRows = dtCart.Select($"ItemID = {itemId}");
            if (existingRows.Length > 0)
            {
                // Update existing row
                int currentQty = Convert.ToInt32(existingRows[0]["Quantity"]);
                existingRows[0]["Quantity"] = currentQty + quantity;
                existingRows[0]["Subtotal"] = price * (currentQty + quantity);
            }
            else
            {
                // Add new row
                dtCart.Rows.Add(itemId, itemName, price, quantity, subtotal);
            }

            ViewState["Cart"] = dtCart;
            BindCart();
            txtQuantity.Text = "1";
        }

        private void BindCart()
        {
            DataTable dtCart = (DataTable)ViewState["Cart"];
        
     if (dtCart.Rows.Count > 0)
  {
       rptCart.DataSource = dtCart;
     rptCart.DataBind();
  pnlCartItems.Visible = true;
            pnlEmptyCart.Visible = false;
   }
  else
     {
       pnlCartItems.Visible = false;
   pnlEmptyCart.Visible = true;
     }

    // Calculate Total with PHP format
    decimal total = 0;
  foreach (DataRow row in dtCart.Rows)
       {
   total += Convert.ToDecimal(row["Subtotal"]);
 }
            lblTotal.Text = "PHP " + total.ToString("N2");
      ViewState["CartTotal"] = total;
        }

        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            // Rate limit: 1 order per 5 seconds per session
            if (!RateLimiter.CanSubmitOrder(Session.SessionID))
            {
                ShowMessage("Please wait 5 seconds before submitting another order.", false);
                return;
            }

            DataTable dtCart = (DataTable)ViewState["Cart"];
   if (dtCart == null || dtCart.Rows.Count ==0)
    {
 ShowMessage("Cart is empty! Please add items first.", false);
   return;
            }

   string orderType = Session["CurrentOrderType"] != null ? Session["CurrentOrderType"].ToString() : "Walk-in";
     decimal totalAmount = ViewState["CartTotal"] != null ? (decimal)ViewState["CartTotal"] :0;
string paymentMethod = ddlPaymentMethod.SelectedValue;

    // Validate required inputs based on order type
 string customerName = (txtCustomerName.Text ?? string.Empty).Trim();
 var txtContactLocal = FindControl("txtContact") as System.Web.UI.WebControls.TextBox;
 var txtAddressLocal = FindControl("txtAddress") as System.Web.UI.WebControls.TextBox;
 var ddlTableNumberLocal = FindControl("ddlTableNumber") as System.Web.UI.WebControls.DropDownList;
 string contact = (txtContactLocal != null ? txtContactLocal.Text : string.Empty).Trim();
 string address = (txtAddressLocal != null ? txtAddressLocal.Text : string.Empty).Trim();
 string tableNumber = (ddlTableNumberLocal != null ? ddlTableNumberLocal.SelectedValue : string.Empty);

 var txtGcashReferenceLocal = FindControl("txtGcashReference") as System.Web.UI.WebControls.TextBox;
 string gcashRef = (txtGcashReferenceLocal != null ? txtGcashReferenceLocal.Text : string.Empty).Trim();

 if (orderType == "Dine-in")
 {
 if (string.IsNullOrEmpty(tableNumber))
 {
 ShowMessage("Please select a table number.", false);
 return;
 }
 // For dine-in staff entry, name is optional
 if (string.IsNullOrEmpty(customerName)) customerName = "Table " + tableNumber;
 }
 else if (orderType == "Delivery")
 {
 if (string.IsNullOrEmpty(customerName))
 {
 ShowMessage("Please provide the customer's full name.", false);
 return;
 }
 if (string.IsNullOrEmpty(contact))
 {
 ShowMessage("Please provide a contact number for delivery.", false);
 return;
 }
 if (string.IsNullOrEmpty(address))
 {
 ShowMessage("Please provide a delivery address.", false);
 return;
 }
 }
 else if (orderType == "Takeout")
 {
 // Takeout only needs full name
 if (string.IsNullOrEmpty(customerName))
 {
 ShowMessage("Please provide the customer's full name for takeout.", false);
 return;
 }
 }

 if (paymentMethod == "GCash" && string.IsNullOrEmpty(gcashRef))
 {
 ShowMessage("GCash reference number is required.", false);
 return;
 }

 try
 {
 using (SqlConnection conn = new SqlConnection(connString))
 {
 conn.Open();
 SqlTransaction transaction = conn.BeginTransaction();

 try
 {
 // Staff/Admin orders should also go to approval, per requirements
 string orderQuery = @"INSERT INTO Orders 
 (OrderType, CustomerName, TableNumber, Address, ContactNumber, PaymentMethod, ReferenceNumber, PaymentStatus, OrderStatus, TotalAmount) 
 OUTPUT INSERTED.OrderID 
 VALUES (@Type, @Name, @Table, @Address, @Contact, @Method, @Ref, 'Pending', 'Pending', @Total)";

 int newOrderId;
 using (SqlCommand cmdOrder = new SqlCommand(orderQuery, conn, transaction))
 {
 cmdOrder.Parameters.AddWithValue("@Type", orderType);
 cmdOrder.Parameters.AddWithValue("@Name", string.IsNullOrEmpty(customerName) ? "Guest" : customerName);
 cmdOrder.Parameters.AddWithValue("@Table", orderType == "Dine-in" ? (object)tableNumber : DBNull.Value);
 cmdOrder.Parameters.AddWithValue("@Address", orderType == "Delivery" ? (object)address : DBNull.Value);
 cmdOrder.Parameters.AddWithValue("@Contact", (object)contact ?? DBNull.Value);
 cmdOrder.Parameters.AddWithValue("@Method", paymentMethod);
 cmdOrder.Parameters.AddWithValue("@Ref", paymentMethod == "GCash" ? (object)gcashRef : DBNull.Value);
 cmdOrder.Parameters.AddWithValue("@Total", totalAmount);

                            try
                            {
                                newOrderId = (int)cmdOrder.ExecuteScalar();
                            }
                            catch (SqlException ex) when (ex.Message.Contains("Invalid column name"))
                            {
                                // Legacy schema fallback without Address/ReferenceNumber
                                string legacyOrder = @"INSERT INTO Orders (OrderType, CustomerName, TableNumber, ContactNumber, PaymentMethod, PaymentStatus, OrderStatus, TotalAmount) 
 OUTPUT INSERTED.OrderID 
 VALUES (@Type, @Name, @Table, @Contact, @Method, 'Pending', 'Pending', @Total)";
                                using (SqlCommand legacyCmd = new SqlCommand(legacyOrder, conn, transaction))
                                {
                                    legacyCmd.Parameters.AddWithValue("@Type", orderType);
                                    legacyCmd.Parameters.AddWithValue("@Name", string.IsNullOrEmpty(customerName) ? "Guest" : customerName);
                                    legacyCmd.Parameters.AddWithValue("@Table", orderType == "Dine-in" ? (object)tableNumber : DBNull.Value);
                                    legacyCmd.Parameters.AddWithValue("@Contact", (object)contact ?? DBNull.Value);
                                    legacyCmd.Parameters.AddWithValue("@Method", paymentMethod);
                                    legacyCmd.Parameters.AddWithValue("@Total", totalAmount);
                                    newOrderId = (int)legacyCmd.ExecuteScalar();
                                }
                            }
 }

 foreach (DataRow row in dtCart.Rows)
 {
 string itemQuery = "INSERT INTO Order_Item (OrderID, ItemSequence, ItemID, Quantity, Subtotal) VALUES (@OrderID,0, @ItemID, @Qty, @Sub)";
 using (SqlCommand cmdItem = new SqlCommand(itemQuery, conn, transaction))
 {
 cmdItem.Parameters.AddWithValue("@OrderID", newOrderId);
 cmdItem.Parameters.AddWithValue("@ItemID", row["ItemID"]);
 cmdItem.Parameters.AddWithValue("@Qty", row["Quantity"]);
 cmdItem.Parameters.AddWithValue("@Sub", row["Subtotal"]);
 cmdItem.ExecuteNonQuery();
 }
 }

 transaction.Commit();

 InitializeCart();
 txtCustomerName.Text = "";
 if (txtContactLocal != null) txtContactLocal.Text = "";
 if (txtAddressLocal != null) txtAddressLocal.Text = "";
 if (ddlTableNumberLocal != null) ddlTableNumberLocal.ClearSelection();
 // Clear GCash ref after commit
 if (txtGcashReferenceLocal != null) txtGcashReferenceLocal.Text = "";

 ShowMessage($"Order #{newOrderId} submitted for approval.", true);
 }
 catch (Exception ex)
 {
 transaction.Rollback();
 ShowMessage("Checkout Failed: " + ex.Message, false);
 }
 }
 }
 catch (Exception ex)
 {
 ShowMessage("Database Error: " + ex.Message, false);
 }
}

   private void DeductInventory(SqlConnection conn, SqlTransaction transaction, int itemId, int quantity)
  {
    // Try to use Recipe mapping first
     string recipeQuery = @"UPDATE Inventory 
 SET StockLevel = StockLevel - (r.QuantityNeeded * @Qty), LastUpdated = GETDATE()
            FROM Inventory i
  INNER JOIN Recipe r ON i.InventoryID = r.InventoryID
           WHERE r.ItemID = @ItemID";
     
    using (SqlCommand cmd = new SqlCommand(recipeQuery, conn, transaction))
  {
   cmd.Parameters.AddWithValue("@ItemID", itemId);
       cmd.Parameters.AddWithValue("@Qty", quantity);
 int rowsAffected = cmd.ExecuteNonQuery();
   
 // If no recipe mapping, do a simplified deduction for wing items
  if (rowsAffected == 0)
  {
   // Check if item name contains "Wing" and deduct from chicken wings
         string checkQuery = "SELECT ItemName FROM Menu_Item WHERE ItemID = @ItemID AND ItemName LIKE '%Wing%'";
   using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn, transaction))
        {
   checkCmd.Parameters.AddWithValue("@ItemID", itemId);
           object result = checkCmd.ExecuteScalar();
 if (result != null)
         {
  string simpleDeduct = "UPDATE Inventory SET StockLevel = StockLevel - @Qty WHERE IngredientName = 'Chicken Wings'";
using (SqlCommand deductCmd = new SqlCommand(simpleDeduct, conn, transaction))
     {
       deductCmd.Parameters.AddWithValue("@Qty", quantity);
      deductCmd.ExecuteNonQuery();
  }
      }
     }
         }
            }
 }

        private void ShowMessage(string message, bool isSuccess)
    {
       lblCheckoutMsg.Text = message;
       lblCheckoutMsg.CssClass = isSuccess ? "message success" : "message error";
  lblCheckoutMsg.Visible = true;
   }
 }
}