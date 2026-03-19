using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using UNLTDWingsApp.Utilities;

namespace UNLTDWingsApp
{
    public partial class GuestCart : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            bool isGuest = Session["IsGuest"] != null && Session["IsGuest"] is bool && (bool)Session["IsGuest"];
      bool isTable = Session["IsTableAccount"] != null && Session["IsTableAccount"] is bool && (bool)Session["IsTableAccount"];

            // Must be in guest flow (Takeout/Delivery) or a table account flow
       if (!isGuest && !isTable)
     {
        Response.Redirect("GuestWelcome.aspx");
        return;
            }

     if (!IsPostBack)
    {
       string displayName = (Session["GuestName"] ?? (isTable ? "Table" : "Guest")).ToString();
           lblGuestName.Text = string.IsNullOrWhiteSpace(displayName) ? "Guest" : displayName;

        string orderType = (Session["GuestOrderType"] ?? "Takeout").ToString();

      // Enforce guest/table order type constraints
           if (isTable)
        {
         orderType = "Dine-in";
             Session["GuestOrderType"] = "Dine-in";
lblAccountType.Text = "Table Account";
           
      // Table dine-in: show table info, hide guest fields
         pnlGuestFields.Visible = false;
            pnlTableInfo.Visible = true;
           lblTableNum.Text = (Session["TableNumber"] ?? "").ToString();
            }
       else
    {
        // Guests cannot do dine-in
if (orderType == "Dine-in")
     {
            orderType = "Takeout";
            Session["GuestOrderType"] = "Takeout";
      }
          lblAccountType.Text = "Guest";
     
               // Guest flow: show guest fields, hide table info
   pnlGuestFields.Visible = true;
                 pnlTableInfo.Visible = false;
    
           // Show/hide fields based on order type
         pnlAddress.Visible = orderType == "Delivery";
          pnlContactField.Visible = orderType == "Delivery"; // Takeout only needs name
     }

                lblOrderType.Text = orderType;

              // Pre-fill name if already known
     if (Session["GuestName"] != null)
    {
        txtGuestName.Text = Session["GuestName"].ToString();
   }

     // Default payment method
           ddlPaymentMethod.SelectedValue = "Cash";
            pnlGcash.Visible = false;

            BindCart();
   }
    }

        protected void ddlPaymentMethod_SelectedIndexChanged(object sender, EventArgs e)
        {
 pnlGcash.Visible = ddlPaymentMethod.SelectedValue == "GCash";
        }

  private void BindCart()
        {
   if (Session["GuestCart"] == null)
   {
         pnlCart.Visible = false;
      pnlEmptyCart.Visible = true;
 return;
  }

            DataTable dtCart = (DataTable)Session["GuestCart"];

      if (dtCart.Rows.Count == 0)
{
        pnlCart.Visible = false;
         pnlEmptyCart.Visible = true;
       return;
         }

            rptCartItems.DataSource = dtCart;
            rptCartItems.DataBind();

    // Calculate totals
            decimal subtotal = 0;
 int itemCount = 0;
      foreach (DataRow row in dtCart.Rows)
      {
       subtotal += Convert.ToDecimal(row["Subtotal"]);
         itemCount += Convert.ToInt32(row["Quantity"]);
         }

     lblSubtotal.Text = "PHP " + subtotal.ToString("N2");
            lblItemCount.Text = itemCount.ToString() + " item" + (itemCount > 1 ? "s" : "");
       lblTotal.Text = "PHP " + subtotal.ToString("N2");

      pnlCart.Visible = true;
            pnlEmptyCart.Visible = false;
      }

        protected void rptCartItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
  DataTable dtCart = (DataTable)Session["GuestCart"];
          int itemId = int.Parse(e.CommandArgument.ToString());

            DataRow[] rows = dtCart.Select($"ItemID = {itemId}");
            if (rows.Length == 0) return;

            DataRow row = rows[0];
        decimal price = Convert.ToDecimal(row["Price"]);
         int currentQty = Convert.ToInt32(row["Quantity"]);

            switch (e.CommandName)
        {
          case "Increase":
       row["Quantity"] = currentQty + 1;
   row["Subtotal"] = price * (currentQty + 1);
            break;

     case "Decrease":
          if (currentQty > 1)
                    {
   row["Quantity"] = currentQty - 1;
     row["Subtotal"] = price * (currentQty - 1);
      }
    else
         {
     row.Delete();
         }
     break;

     case "Remove":
             row.Delete();
   break;
      }

         Session["GuestCart"] = dtCart;
            BindCart();
   }

  protected void btnSubmitOrder_Click(object sender, EventArgs e)
        {
     // Rate limit: 1 order per 5 seconds per session
  if (!RateLimiter.CanSubmitOrder(Session.SessionID))
       {
  lblMessage.Text = "Please wait 5 seconds before submitting another order.";
  return;
  }

       DataTable dtCart = (DataTable)Session["GuestCart"];
            if (dtCart == null || dtCart.Rows.Count == 0)
   {
        lblMessage.Text = "Your cart is empty!";
  return;
    }

 bool isTable = Session["IsTableAccount"] != null && Session["IsTableAccount"] is bool && (bool)Session["IsTableAccount"];
          string orderType = (Session["GuestOrderType"] ?? "Takeout").ToString();
    string paymentMethod = ddlPaymentMethod.SelectedValue;
            string gcashRef = (txtGcashReference.Text ?? string.Empty).Trim();

       string guestName;
            string contact;
    string address;
  string tableNumber = null;

if (isTable)
   {
        // Table account: dine-in, use table info from session
     guestName = (Session["GuestName"] ?? "Guest").ToString();
     contact = "";
       address = "";
 tableNumber = (Session["TableNumber"] ?? "").ToString();
      }
            else
            {
    guestName = (txtGuestName.Text ?? string.Empty).Trim();
    contact = (txtContact.Text ?? string.Empty).Trim();
         address = (txtAddress.Text ?? string.Empty).Trim();

     if (string.IsNullOrEmpty(guestName))
        {
   guestName = "Guest";
     }

      // Persist guest name for order tracking
   Session["GuestName"] = guestName;

           if (orderType == "Delivery")
        {
   if (string.IsNullOrEmpty(contact))
   {
       lblMessage.Text = "Contact number is required for delivery.";
   return;
   }
    if (string.IsNullOrEmpty(address))
        {
    lblMessage.Text = "Delivery address is required.";
            return;
          }
  }
     else if (orderType == "Takeout")
              {
            // Takeout only requires full name
     if (guestName == "Guest" || string.IsNullOrEmpty(guestName))
          {
    lblMessage.Text = "Please enter your full name for takeout.";
 return;
       }
        }
            }

        // GCash validation (applies to all order types)
  if (paymentMethod == "GCash")
{
           if (!RateLimiter.CanSubmitGCashReference(Session.SessionID))
      {
         lblMessage.Text = "Please wait before submitting GCash reference again.";
return;
         }
      if (string.IsNullOrEmpty(gcashRef))
      {
           lblMessage.Text = "GCash reference number is required. Please paste your reference no.";
     return;
    }
            }

       try
          {
    using (SqlConnection conn = new SqlConnection(connString))
      {
           conn.Open();
         SqlTransaction transaction = conn.BeginTransaction();

       try
{
     decimal total = 0;
 foreach (DataRow row in dtCart.Rows)
       {
            total += Convert.ToDecimal(row["Subtotal"]);
         }

    string orderQuery = @"INSERT INTO Orders (CustomerName, OrderType, TableNumber, OrderStatus, PaymentStatus, TotalAmount, Address, ContactNumber, PaymentMethod, ReferenceNumber)
 OUTPUT INSERTED.OrderID
 VALUES (@Name, @Type, @Table, 'Pending', 'Pending', @Total, @Address, @Contact, @Method, @Ref)";

      int orderId;
          using (SqlCommand cmd = new SqlCommand(orderQuery, conn, transaction))
       {
       cmd.Parameters.AddWithValue("@Name", guestName);
     cmd.Parameters.AddWithValue("@Type", orderType);
        cmd.Parameters.AddWithValue("@Table", !string.IsNullOrEmpty(tableNumber) ? (object)tableNumber : DBNull.Value);
                  cmd.Parameters.AddWithValue("@Total", total);
       cmd.Parameters.AddWithValue("@Address", orderType == "Delivery" ? (object)address : DBNull.Value);
      cmd.Parameters.AddWithValue("@Contact", !string.IsNullOrEmpty(contact) ? (object)contact : DBNull.Value);
       cmd.Parameters.AddWithValue("@Method", paymentMethod);
  cmd.Parameters.AddWithValue("@Ref", paymentMethod == "GCash" ? (object)gcashRef : DBNull.Value);

    try
       {
  orderId = (int)cmd.ExecuteScalar();
           }
      catch (SqlException ex) when (ex.Message.Contains("Invalid column name"))
              {
    // Legacy schema fallback
 string legacyOrderQuery = @"INSERT INTO Orders (CustomerName, OrderType, OrderStatus, PaymentStatus, TotalAmount, ContactNumber, PaymentMethod)
 OUTPUT INSERTED.OrderID
 VALUES (@Name, @Type, 'Pending', 'Pending', @Total, @Contact, @Method)";
    using (SqlCommand legacy = new SqlCommand(legacyOrderQuery, conn, transaction))
      {
       legacy.Parameters.AddWithValue("@Name", guestName);
 legacy.Parameters.AddWithValue("@Type", orderType);
     legacy.Parameters.AddWithValue("@Total", total);
         legacy.Parameters.AddWithValue("@Contact", !string.IsNullOrEmpty(contact) ? (object)contact : DBNull.Value);
          legacy.Parameters.AddWithValue("@Method", paymentMethod);
        orderId = (int)legacy.ExecuteScalar();
            }
          }
        }

    foreach (DataRow row in dtCart.Rows)
   {
  string itemQuery = "INSERT INTO Order_Item (OrderID, ItemSequence, ItemID, Quantity, Subtotal) VALUES (@OrderID, 0, @ItemID, @Qty, @Sub)";
     using (SqlCommand cmd = new SqlCommand(itemQuery, conn, transaction))
        {
       cmd.Parameters.AddWithValue("@OrderID", orderId);
          cmd.Parameters.AddWithValue("@ItemID", row["ItemID"]);
          cmd.Parameters.AddWithValue("@Qty", row["Quantity"]);
  cmd.Parameters.AddWithValue("@Sub", row["Subtotal"]);
       cmd.ExecuteNonQuery();
                  }
             }

      transaction.Commit();

       // Clear cart and show success
          dtCart.Rows.Clear();
     Session["GuestCart"] = dtCart;

         // Store last order id for MyOrders page
     Session["LastGuestOrderID"] = orderId;

        // Add this order to the session's list
       if (Session["GuestOrderIDs"] == null)
       {
      Session["GuestOrderIDs"] = new System.Collections.Generic.List<int>();
            }
   var orderList = (System.Collections.Generic.List<int>)Session["GuestOrderIDs"];
      orderList.Add(orderId);
          Session["GuestOrderIDs"] = orderList;

     pnlSuccess.Visible = true;
     pnlCart.Visible = false;
      pnlEmptyCart.Visible = false;
    lblMessage.Text = "";
      }
      catch (Exception ex)
    {
            transaction.Rollback();
         lblMessage.Text = "Failed to submit order: " + ex.Message;
           }
          }
      }
         catch (Exception ex)
       {
  lblMessage.Text = "Database error: " + ex.Message;
     }
    }

        protected void btnLogout_Click(object sender, EventArgs e)
      {
    Session.Clear();
            Response.Redirect("Login.aspx");
        }
    }
}
