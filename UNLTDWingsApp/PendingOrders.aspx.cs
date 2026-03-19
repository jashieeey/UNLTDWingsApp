using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class PendingOrders : System.Web.UI.Page
    {
     string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
      if (Session["UserID"] == null)
       {
                Response.Redirect("Login.aspx");
          return;
          }

          string role = (Session["Role"] ?? string.Empty).ToString();
 if (!role.Equals("Staff", StringComparison.OrdinalIgnoreCase) && !role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
 {
 Response.Redirect("GuestMenu.aspx");
 return;
 }

          if (!IsPostBack)
    {
     LoadPendingOrders();
            }
    }

    protected void btnBack_Click(object sender, EventArgs e)
        {
    Response.Redirect("Dashboard.aspx");
        }

private void LoadPendingOrders()
        {
 try
            {
using (SqlConnection conn = new SqlConnection(connString))
     {
     // Query gets all order details including Address, ContactNumber, PaymentMethod, ReferenceNumber
   string query = @"
       SELECT 
          OrderID, 
       CustomerName, 
      TableNumber, 
       OrderType,
          Address,
           ContactNumber,
          PaymentMethod,
          ReferenceNumber,
     OrderDate, 
                    TotalAmount 
        FROM Orders 
                 WHERE OrderStatus = 'Pending' 
        ORDER BY OrderDate ASC";

  SqlDataAdapter da = new SqlDataAdapter(query, conn);
         DataTable dt = new DataTable();
        da.Fill(dt);

       if (dt.Rows.Count > 0)
{
       rptOrders.DataSource = dt;
      rptOrders.DataBind();
         lblCount.Text = dt.Rows.Count.ToString();
        pnlEmpty.Visible = false;
         }
       else
    {
       rptOrders.DataSource = null;
      rptOrders.DataBind();
        lblCount.Text = "0";
          pnlEmpty.Visible = true;
     }
            }
      }
     catch (Exception ex)
      {
     System.Diagnostics.Debug.WriteLine("Error loading pending orders: " + ex.Message);
   pnlEmpty.Visible = true;
                lblCount.Text = "0";
            }
        }

    protected DataTable GetOrderItems(int orderId)
        {
            DataTable dt = new DataTable();
         try
            {
     using (SqlConnection conn = new SqlConnection(connString))
   {
            string query = @"
   SELECT 
  m.ItemName, 
      oi.Quantity, 
  oi.Subtotal 
    FROM Order_Item oi
        INNER JOIN Menu_Item m ON oi.ItemID = m.ItemID
          WHERE oi.OrderID = @OrderID
   ORDER BY oi.ItemSequence";
         
          using (SqlCommand cmd = new SqlCommand(query, conn))
        {
        cmd.Parameters.AddWithValue("@OrderID", orderId);
      SqlDataAdapter da = new SqlDataAdapter(cmd);
    da.Fill(dt);
         }
        }
     }
            catch (Exception ex)
{
      System.Diagnostics.Debug.WriteLine("Error getting order items: " + ex.Message);
            }
            return dt;
        }

     protected void rptOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
      // Bind nested repeater for items
      Repeater rptItems = (Repeater)e.Item.FindControl("rptItems");
     if (rptItems != null)
             {
     DataRowView drv = (DataRowView)e.Item.DataItem;
   int orderId = Convert.ToInt32(drv["OrderID"]);
        rptItems.DataSource = GetOrderItems(orderId);
          rptItems.DataBind();
           }
      }
   }

        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int orderId = int.Parse(e.CommandArgument.ToString());
    int userId = int.Parse(Session["UserID"].ToString());

      string newStatus = e.CommandName == "Approve" ? "Approved" : "Cancelled";
     string newPaymentStatus = e.CommandName == "Approve" ? "Paid" : "Pending";

            try
       {
           using (SqlConnection conn = new SqlConnection(connString))
    {
 // Update order status and payment status together
                string query = @"
               UPDATE Orders 
               SET OrderStatus = @Status,
                   PaymentStatus = @PayStatus,
                ApprovedBy = @ApprovedBy, 
   ApprovedDate = GETDATE() 
    WHERE OrderID = @OrderID";
         
          using (SqlCommand cmd = new SqlCommand(query, conn))
          {
      cmd.Parameters.AddWithValue("@Status", newStatus);
                 cmd.Parameters.AddWithValue("@PayStatus", newPaymentStatus);
          cmd.Parameters.AddWithValue("@ApprovedBy", userId);
         cmd.Parameters.AddWithValue("@OrderID", orderId);
  
    conn.Open();
  cmd.ExecuteNonQuery();
   }

            // Log approval/rejection in OrderApprovals table if it exists
        try
     {
      string approvalStatus = e.CommandName == "Approve" ? "Approved" : "Rejected";
             string approvalQuery = @"
            INSERT INTO OrderApprovals (OrderID, ApprovedByUserID, ApprovalStatus, ApprovedDate)
         VALUES (@OrderID, @UserID, @Status, GETDATE())";
        
    using (SqlCommand cmd = new SqlCommand(approvalQuery, conn))
       {
         cmd.Parameters.AddWithValue("@OrderID", orderId);
         cmd.Parameters.AddWithValue("@UserID", userId);
       cmd.Parameters.AddWithValue("@Status", approvalStatus);
      cmd.ExecuteNonQuery();
 }
     }
         catch
         {
        // OrderApprovals table may not exist yet - continue anyway
   }
              }

            // If approved, deduct inventory
        if (e.CommandName == "Approve")
     {
        DeductInventoryForOrder(orderId);
         }

      LoadPendingOrders();
       }
            catch (Exception ex)
            {
         System.Diagnostics.Debug.WriteLine("Error updating order: " + ex.Message);
         LoadPendingOrders();
   }
        }

    private void DeductInventoryForOrder(int orderId)
{
       try
            {
    using (SqlConnection conn = new SqlConnection(connString))
   {
          conn.Open();
    
         // Get order items with their recipes
        string itemsQuery = @"
SELECT 
     oi.ItemID, 
      oi.Quantity
 FROM Order_Item oi
     WHERE oi.OrderID = @OrderID";
   
       DataTable dtItems = new DataTable();
        using (SqlCommand cmd = new SqlCommand(itemsQuery, conn))
           {
      cmd.Parameters.AddWithValue("@OrderID", orderId);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
           da.Fill(dtItems);
       }

    // For each item, deduct from inventory based on Recipe table
       foreach (DataRow row in dtItems.Rows)
    {
       int itemId = Convert.ToInt32(row["ItemID"]);
  int orderQuantity = Convert.ToInt32(row["Quantity"]);

        // Get recipe for this item
    string recipeQuery = @"
       SELECT 
    InventoryID, 
   QuantityNeeded 
        FROM Recipe 
   WHERE ItemID = @ItemID";
     
  DataTable dtRecipe = new DataTable();
           using (SqlCommand cmd = new SqlCommand(recipeQuery, conn))
   {
         cmd.Parameters.AddWithValue("@ItemID", itemId);
        SqlDataAdapter da = new SqlDataAdapter(cmd);
    da.Fill(dtRecipe);
   }

      // Deduct inventory for each ingredient - prevent negative stock
    foreach (DataRow recipeRow in dtRecipe.Rows)
    {
   int inventoryId = Convert.ToInt32(recipeRow["InventoryID"]);
        decimal quantityNeeded = Convert.ToDecimal(recipeRow["QuantityNeeded"]);
         decimal totalDeductible = quantityNeeded * orderQuantity;

         string deductQuery = @"
    UPDATE Inventory 
  SET StockLevel = CASE WHEN StockLevel - @Amount < 0 THEN 0 ELSE StockLevel - @Amount END,
    LastUpdated = GETDATE()
    WHERE InventoryID = @InventoryID";
     
   using (SqlCommand cmd = new SqlCommand(deductQuery, conn))
         {
      cmd.Parameters.AddWithValue("@Amount", totalDeductible);
   cmd.Parameters.AddWithValue("@InventoryID", inventoryId);
      cmd.ExecuteNonQuery();
      }
  }

  // Fallback: if no recipe found, try simplified deduction for wing items
  if (dtRecipe.Rows.Count == 0)
  {
  string checkQuery = "SELECT ItemName, ItemCategory FROM Menu_Item WHERE ItemID = @ItemID";
      using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
    {
       checkCmd.Parameters.AddWithValue("@ItemID", itemId);
   using (SqlDataReader reader = checkCmd.ExecuteReader())
 {
      if (reader.Read())
        {
             string itemName = reader["ItemName"].ToString();
    string category = reader["ItemCategory"].ToString();
   reader.Close();

                  if (category == "Wings" || category == "Unlimited" || itemName.Contains("Wing"))
    {
      string simpleDeduct = @"UPDATE Inventory 
     SET StockLevel = CASE WHEN StockLevel - @Qty < 0 THEN 0 ELSE StockLevel - @Qty END, 
                LastUpdated = GETDATE() 
   WHERE IngredientName = 'Chicken Wings'";
       using (SqlCommand deductCmd = new SqlCommand(simpleDeduct, conn))
      {
         deductCmd.Parameters.AddWithValue("@Qty", orderQuantity);
           deductCmd.ExecuteNonQuery();
            }
                  }
    }
          }
      }
  }
        }
    }
   }
    catch (Exception ex)
            {
      System.Diagnostics.Debug.WriteLine("Error deducting inventory: " + ex.Message);
      // Don't stop the process if inventory deduction fails
  }
        }

        protected string GetOrderTypeCss(string orderType)
 {
 if (string.IsNullOrWhiteSpace(orderType)) return "takeout";
 switch (orderType.Trim())
 {
 case "Dine-in": return "dine-in";
 case "Delivery": return "delivery";
 case "Takeout":
 case "Take-out": return "takeout";
 default: return "takeout";
 }
 }
    }
}
