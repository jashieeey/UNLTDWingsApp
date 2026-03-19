using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class TodaysOrders : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;
        
        private string CurrentFilter
    {
   get { return ViewState["CurrentFilter"] as string ?? ""; }
          set { ViewState["CurrentFilter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
     // Check authentication
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
        LoadTodaysOrders("");
            }
        }

        /// <summary>
  /// Load all orders from today
        /// </summary>
 private void LoadTodaysOrders(string filterType)
  {
   try
    {
     using (SqlConnection conn = new SqlConnection(connString))
       {
        string query = @"
SELECT 
    o.OrderID,
    o.CustomerName,
    o.OrderType,
    o.OrderDate,
    o.TotalAmount,
    o.OrderStatus,
    o.TableNumber,
    o.Address,
    o.ContactNumber,
    o.PaymentMethod,
    o.ReferenceNumber
FROM Orders o
WHERE CAST(o.OrderDate AS DATE) = CAST(GETDATE() AS DATE)";

          // Add filter if specified
          if (!string.IsNullOrEmpty(filterType))
        {
    query += " AND o.OrderType = @OrderType";
              }

            // Add search filter if applied
    if (!string.IsNullOrEmpty(txtSearch.Text))
    {
      query += @" AND (CAST(o.OrderID AS NVARCHAR(50)) LIKE @SearchTerm 
 OR o.CustomerName LIKE @SearchTerm)";
         }

    query += " ORDER BY o.OrderDate DESC";

     using (SqlCommand cmd = new SqlCommand(query, conn))
              {
     if (!string.IsNullOrEmpty(filterType))
      {
cmd.Parameters.AddWithValue("@OrderType", filterType);
  }

         if (!string.IsNullOrEmpty(txtSearch.Text))
       {
    cmd.Parameters.AddWithValue("@SearchTerm", "%" + txtSearch.Text + "%");
     }

          SqlDataAdapter da = new SqlDataAdapter(cmd);
  DataTable dt = new DataTable();
       da.Fill(dt);

       if (dt.Rows.Count > 0)
           {
          rptOrders.DataSource = dt;
    rptOrders.DataBind();
         pnlOrders.Visible = true;
          pnlEmpty.Visible = false;

      // Load summary
      UpdateSummary(dt);
     }
             else
          {
 pnlOrders.Visible = false;
         pnlEmpty.Visible = true;
            lblOrderCount.Text = "0";
     lblActiveCount.Text = "0";
             lblCompletedCount.Text = "0";
           lblTotalRevenue.Text = "0.00";
      lblLowStockCount.Text = "0";
             }
       }
     }

         // Load low-stock count for the summary card
          LoadLowStockCount();
            }
    catch (Exception ex)
{
    System.Diagnostics.Debug.WriteLine("Error loading today's orders: " + ex.Message);
           pnlOrders.Visible = false;
           pnlEmpty.Visible = true;
  }
        }

 /// <summary>
   /// Update summary statistics
        /// </summary>
        private void UpdateSummary(DataTable dt)
     {
    try
            {
             int totalOrders = dt.Rows.Count;
        int activeCount = 0;
          int completedCount = 0;
                decimal totalRevenue = 0;

      foreach (DataRow row in dt.Rows)
  {
        string status = row["OrderStatus"].ToString();
          if (status == "Pending" || status == "Approved")
           {
                 activeCount++;
        }
             else if (status == "Completed")
           {
      completedCount++;
    }

  if (status != "Cancelled")
         {
        totalRevenue += Convert.ToDecimal(row["TotalAmount"]);
              }
}

          lblOrderCount.Text = totalOrders.ToString();
       lblActiveCount.Text = activeCount.ToString();
    lblCompletedCount.Text = completedCount.ToString();
     lblTotalRevenue.Text = totalRevenue.ToString("N2");
         }
            catch (Exception ex)
            {
       System.Diagnostics.Debug.WriteLine("Error updating summary: " + ex.Message);
      }
      }

        /// <summary>
  /// Load count of low-stock inventory items
 /// </summary>
        private void LoadLowStockCount()
     {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
    {
   string query = "SELECT COUNT(*) FROM Inventory WHERE StockLevel <= ReorderLevel AND StockLevel > 0";
   using (SqlCommand cmd = new SqlCommand(query, conn))
       {
     conn.Open();
     object result = cmd.ExecuteScalar();
   lblLowStockCount.Text = (result != null) ? Convert.ToInt32(result).ToString() : "0";
            }
      }
    }
       catch
         {
  lblLowStockCount.Text = "0";
 }
        }

        /// <summary>
        /// Get item count for order
        /// </summary>
     public int GetItemCount(int orderId)
        {
       try
     {
  using (SqlConnection conn = new SqlConnection(connString))
         {
    string query = "SELECT COUNT(*) FROM Order_Item WHERE OrderID = @OrderID";
         using (SqlCommand cmd = new SqlCommand(query, conn))
         {
        cmd.Parameters.AddWithValue("@OrderID", orderId);
     conn.Open();
             object result = cmd.ExecuteScalar();
       return (result != null) ? Convert.ToInt32(result) : 0;
     }
                }
         }
            catch
     {
     return 0;
            }
        }

        /// <summary>
/// Get order items with stock level information
        /// </summary>
        private DataTable GetOrderItemsWithStock(int orderId)
   {
  DataTable dt = new DataTable();
     try
      {
     using (SqlConnection conn = new SqlConnection(connString))
       {
      // Join Order_Item -> Menu_Item, then find the minimum stock from Recipe->Inventory
             string query = @"
SELECT 
    m.ItemName,
    oi.Quantity,
    oi.Subtotal,
    ISNULL(
        (SELECT MIN(i.StockLevel)
         FROM Recipe r
         INNER JOIN Inventory i ON r.InventoryID = i.InventoryID
  WHERE r.ItemID = oi.ItemID), -1
    ) AS StockLevel
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
   System.Diagnostics.Debug.WriteLine("Error getting order items with stock: " + ex.Message);
}
      return dt;
        }

        /// <summary>
        /// Check overall stock availability for an order (used in main row)
      /// </summary>
        private string GetOrderStockStatus(int orderId)
 {
            try
            {
  using (SqlConnection conn = new SqlConnection(connString))
      {
             // Check if any ingredient for any item in this order is out of stock or low
   string query = @"
SELECT 
    MIN(i.StockLevel) AS MinStock,
    MIN(i.ReorderLevel) AS MinReorder
FROM Order_Item oi
INNER JOIN Recipe r ON oi.ItemID = r.ItemID
INNER JOIN Inventory i ON r.InventoryID = i.InventoryID
WHERE oi.OrderID = @OrderID";

   using (SqlCommand cmd = new SqlCommand(query, conn))
    {
       cmd.Parameters.AddWithValue("@OrderID", orderId);
     conn.Open();
  using (SqlDataReader reader = cmd.ExecuteReader())
     {
     if (reader.Read() && reader["MinStock"] != DBNull.Value)
    {
  decimal minStock = Convert.ToDecimal(reader["MinStock"]);
     decimal minReorder = reader["MinReorder"] != DBNull.Value ? Convert.ToDecimal(reader["MinReorder"]) : 10;

       if (minStock <= 0)
 return "<span class='stock-badge out'><i class='bi bi-x-circle-fill'></i> Out</span>";
      else if (minStock <= minReorder)
     return "<span class='stock-badge low'><i class='bi bi-exclamation-triangle-fill'></i> Low</span>";
        else
    return "<span class='stock-badge ok'><i class='bi bi-check-circle-fill'></i> OK</span>";
       }
   }
   }
   }
      }
catch
  {
   // Fall through to default
 }

    return "<span class='stock-badge ok'><i class='bi bi-check-circle-fill'></i> OK</span>";
        }

 /// <summary>
/// Render a stock badge for individual item rows (called from ASPX markup)
        /// </summary>
        public string GetStockBadge(object stockLevelObj)
        {
            if (stockLevelObj == null || stockLevelObj == DBNull.Value)
     return "<span class='stock-badge ok'>N/A</span>";

            decimal stockLevel = Convert.ToDecimal(stockLevelObj);
            if (stockLevel < 0)
     return "<span class='stock-badge ok'>N/A</span>";
            if (stockLevel <= 0)
            return "<span class='stock-badge out'>Out</span>";
  if (stockLevel <= 10)
    return "<span class='stock-badge low'>" + stockLevel.ToString("N0") + "</span>";

      return "<span class='stock-badge ok'>" + stockLevel.ToString("N0") + "</span>";
        }

        /// <summary>
      /// Get CSS class suffix for order type badges
        /// </summary>
        public string GetOrderTypeCss(string orderType)
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

        /// <summary>
        /// Handle filter tab clicks
        /// </summary>
        protected void FilterTab_Click(object sender, EventArgs e)
        {
       LinkButton btn = (LinkButton)sender;
   string filter = btn.CommandArgument;
      CurrentFilter = filter;

   // Update active tab styling
        btnFilterAll.CssClass = filter == "" ? "filter-tab active" : "filter-tab";
      btnFilterDineIn.CssClass = filter == "Dine-in" ? "filter-tab active" : "filter-tab";
      btnFilterDelivery.CssClass = filter == "Delivery" ? "filter-tab active" : "filter-tab";
btnFilterTakeout.CssClass = filter == "Takeout" ? "filter-tab active" : "filter-tab";

      // Clear search when filtering
   txtSearch.Text = "";
   LoadTodaysOrders(filter);
     }

   /// <summary>
   /// Handle search button click
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
     {
 LoadTodaysOrders(CurrentFilter);
  }

        /// <summary>
     /// Handle clear search button click
        /// </summary>
 protected void btnClearSearch_Click(object sender, EventArgs e)
        {
   txtSearch.Text = "";
      LoadTodaysOrders(CurrentFilter);
 }

        /// <summary>
        /// Handle repeater item data bound - populate detail panels and stock info
        /// </summary>
        protected void rptOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
  if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;
        int orderID = Convert.ToInt32(drv["OrderID"]);
      string orderType = drv["OrderType"].ToString().Trim();

       // --- Store OrderID in dropdown's data attribute ---
     DropDownList ddlStatus = (DropDownList)e.Item.FindControl("ddlStatus");
    if (ddlStatus != null)
      {
        ddlStatus.Attributes.Add("data-orderid", orderID.ToString());
     }

        // --- Populate extra info beside customer name ---
 Literal litExtraInfo = (Literal)e.Item.FindControl("litExtraInfo");
if (litExtraInfo != null)
        {
     string tableNum = drv["TableNumber"] != DBNull.Value ? drv["TableNumber"].ToString() : "";
   if (orderType == "Dine-in" && !string.IsNullOrEmpty(tableNum))
           {
            litExtraInfo.Text = " <span style='font-size:11px;color:#007bff;'><i class='bi bi-table'></i> Table " + Server.HtmlEncode(tableNum) + "</span>";
       }
        else if (orderType == "Delivery")
  {
               string contact = drv["ContactNumber"] != DBNull.Value ? drv["ContactNumber"].ToString() : "";
        if (!string.IsNullOrEmpty(contact))
  litExtraInfo.Text = " <span style='font-size:11px;color:#28a745;'><i class='bi bi-telephone'></i> " + Server.HtmlEncode(contact) + "</span>";
       }
    }

            // --- Populate stock status for main row ---
          Literal litStockStatus = (Literal)e.Item.FindControl("litStockStatus");
              if (litStockStatus != null)
     {
    litStockStatus.Text = GetOrderStockStatus(orderID);
     }

    // --- Populate order-type-specific detail panels ---
     Panel pnlTableInfo = (Panel)e.Item.FindControl("pnlTableInfo");
       Panel pnlDeliveryInfo = (Panel)e.Item.FindControl("pnlDeliveryInfo");
       Panel pnlPaymentInfo = (Panel)e.Item.FindControl("pnlPaymentInfo");

  if (orderType == "Dine-in" && pnlTableInfo != null)
{
       string tableNum = drv["TableNumber"] != DBNull.Value ? drv["TableNumber"].ToString() : "-";
       pnlTableInfo.Visible = true;
           Label lblTableNum = (Label)e.Item.FindControl("lblTableNum");
            if (lblTableNum != null) lblTableNum.Text = Server.HtmlEncode(tableNum);
       }

    if (orderType == "Delivery" && pnlDeliveryInfo != null)
     {
           pnlDeliveryInfo.Visible = true;
         Label lblAddress = (Label)e.Item.FindControl("lblAddress");
    Label lblContact = (Label)e.Item.FindControl("lblContact");
        if (lblAddress != null) lblAddress.Text = Server.HtmlEncode(drv["Address"] != DBNull.Value ? drv["Address"].ToString() : "-");
    if (lblContact != null) lblContact.Text = Server.HtmlEncode(drv["ContactNumber"] != DBNull.Value ? drv["ContactNumber"].ToString() : "-");
         }

                // Payment info for delivery/takeout
    if ((orderType == "Delivery" || orderType == "Takeout" || orderType == "Take-out") && pnlPaymentInfo != null)
         {
 string paymentMethod = drv["PaymentMethod"] != DBNull.Value ? drv["PaymentMethod"].ToString() : "";
        string refNum = drv["ReferenceNumber"] != DBNull.Value ? drv["ReferenceNumber"].ToString() : "";

   if (!string.IsNullOrEmpty(paymentMethod))
  {
 pnlPaymentInfo.Visible = true;
            Label lblPaymentMethod = (Label)e.Item.FindControl("lblPaymentMethod");
        Label lblRefNum = (Label)e.Item.FindControl("lblRefNum");
    if (lblPaymentMethod != null) lblPaymentMethod.Text = Server.HtmlEncode(paymentMethod);
                if (lblRefNum != null && !string.IsNullOrEmpty(refNum))
  lblRefNum.Text = " (Ref: " + Server.HtmlEncode(refNum) + ")";
   }
       }

  // --- Bind nested items repeater with stock info ---
Repeater rptItems = (Repeater)e.Item.FindControl("rptItems");
    if (rptItems != null)
       {
   DataTable dtItems = GetOrderItemsWithStock(orderID);
          rptItems.DataSource = dtItems;
    rptItems.DataBind();
     }
            }
        }

   /// <summary>
        /// Handle status dropdown change
   /// </summary>
     protected void StatusChanged(object sender, EventArgs e)
        {
  try
        {
              DropDownList ddl = (DropDownList)sender;
             // Get the OrderID from the HiddenField in the same repeater item
     RepeaterItem item = (RepeaterItem)ddl.NamingContainer;
    HiddenField hf = (HiddenField)item.FindControl("hfOrderId");
  
      if (hf == null || string.IsNullOrEmpty(hf.Value) || !int.TryParse(hf.Value, out int orderId))
 {
      System.Diagnostics.Debug.WriteLine("Could not extract OrderID from HiddenField");
          return;
      }

     string newStatus = ddl.SelectedValue;

 using (SqlConnection conn = new SqlConnection(connString))
                {
   string query = @"
UPDATE Orders
SET OrderStatus = @Status,
    ApprovedDate = CASE WHEN @Status IN ('Approved','Completed','Cancelled') THEN GETDATE() ELSE ApprovedDate END
WHERE OrderID = @OrderID";

   using (SqlCommand cmd = new SqlCommand(query, conn))
      {
       cmd.Parameters.AddWithValue("@Status", newStatus);
          cmd.Parameters.AddWithValue("@OrderID", orderId);
    conn.Open();
        cmd.ExecuteNonQuery();
      }
    }

    // Reload orders
                LoadTodaysOrders(CurrentFilter);
  }
 catch (Exception ex)
      {
   System.Diagnostics.Debug.WriteLine("Error updating order status: " + ex.Message);
            }
    }

        /// <summary>
        /// Handle repeater item command (Delete)
     /// </summary>
        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
    if (e.CommandName == "Delete")
  {
                int orderId = int.Parse(e.CommandArgument.ToString());

      try
  {
          using (SqlConnection conn = new SqlConnection(connString))
{
        // Delete order items first (FK constraint)
        string deleteItemsQuery = "DELETE FROM Order_Item WHERE OrderID = @OrderID";
      using (SqlCommand cmd = new SqlCommand(deleteItemsQuery, conn))
     {
      cmd.Parameters.AddWithValue("@OrderID", orderId);
       conn.Open();
       cmd.ExecuteNonQuery();
   }

  // Then delete order
               string deleteOrderQuery = "DELETE FROM Orders WHERE OrderID = @OrderID";
          using (SqlCommand cmd = new SqlCommand(deleteOrderQuery, conn))
         {
    cmd.Parameters.AddWithValue("@OrderID", orderId);
   cmd.ExecuteNonQuery();
          }
     }

       // Reload orders
    LoadTodaysOrders(CurrentFilter);
     }
catch (Exception ex)
    {
         System.Diagnostics.Debug.WriteLine("Error deleting order: " + ex.Message);
       }
  }
        }

    /// <summary>
        /// Auto-refresh hidden button handler
     /// </summary>
   protected void btnRefreshHidden_Click(object sender, EventArgs e)
        {
   LoadTodaysOrders(CurrentFilter);
   }

        /// <summary>
        /// Back to Dashboard
        /// </summary>
    protected void btnBack_Click(object sender, EventArgs e)
        {
     Response.Redirect("Dashboard.aspx");
        }
    }
}
