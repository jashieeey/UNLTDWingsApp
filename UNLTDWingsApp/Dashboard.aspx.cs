using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace UNLTDWingsApp
{
    public partial class Dashboard : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Guests (including table accounts) must not access staff dashboard
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Staff", StringComparison.OrdinalIgnoreCase) && !role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Display user info
                lblUserName.Text = Session["UserName"] != null ? Session["UserName"].ToString() : "User";
                lblRole.Text = role;

                // Show admin panel if admin
                pnlAdminActions.Visible = role.Equals("Admin", StringComparison.OrdinalIgnoreCase);

                LoadDashboardStats();
                LoadLowStockAlerts();
            }
        }

        private void LoadDashboardStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Today's sales (completed/paid orders)
                    string salesQuery = @"SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders 
   WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE) 
      AND PaymentStatus = 'Paid'";
                    using (SqlCommand cmd = new SqlCommand(salesQuery, conn))
                    {
                        decimal todaySales = Convert.ToDecimal(cmd.ExecuteScalar());
                        lblTodaySales.Text = todaySales.ToString("N0");
                    }

                    // Today's order count (completed orders only, matching the label)
                     string orderQuery = @"SELECT COUNT(*) FROM Orders 
             WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)
     AND OrderStatus = 'Completed'";
                    using (SqlCommand cmd = new SqlCommand(orderQuery, conn))
                    {
                        int todayOrders = Convert.ToInt32(cmd.ExecuteScalar());
                        lblTodayOrders.Text = todayOrders.ToString();
                    }

                    // Today's refill count
                    string refillQuery = @"SELECT COUNT(*) FROM Refill_Log 
                WHERE CAST(RefillTime AS DATE) = CAST(GETDATE() AS DATE)";
                    using (SqlCommand cmd = new SqlCommand(refillQuery, conn))
                    {
                        int todayRefills = Convert.ToInt32(cmd.ExecuteScalar());
                        lblTodayRefills.Text = todayRefills.ToString();
                    }

                    // Pending orders count (guest orders waiting for approval)
                    string pendingQuery = @"SELECT COUNT(*) FROM Orders WHERE OrderStatus = 'Pending'";
                    using (SqlCommand cmd = new SqlCommand(pendingQuery, conn))
                    {
                        int pendingCount = Convert.ToInt32(cmd.ExecuteScalar());
                        lblPendingCount.Text = pendingCount.ToString();
                        pnlPendingAlert.Visible = pendingCount > 0;
                    }
                }
            }
            catch (Exception)
            {
                // Set default values if DB not available
                lblTodaySales.Text = "0";
                lblTodayOrders.Text = "0";
                lblTodayRefills.Text = "0";
                pnlPendingAlert.Visible = false;
            }
        }

        private void LoadLowStockAlerts()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Get items where stock is at or below reorder level
                    string query = @"SELECT IngredientName, StockLevel, Unit, ReorderLevel 
                FROM Inventory 
        WHERE StockLevel <= ReorderLevel 
  ORDER BY StockLevel ASC";

                    SqlDataAdapter da = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptLowStock.DataSource = dt;
                        rptLowStock.DataBind();
                        pnlLowStock.Visible = true;
                    }
                    else
                    {
                        pnlLowStock.Visible = false;
                    }
                }
            }
            catch (Exception)
            {
                pnlLowStock.Visible = false;
            }
        }

        protected void btnPendingAlert_Click(object sender, EventArgs e)
        {
            Response.Redirect("PendingOrders.aspx");
        }

        protected void btnDelivery_Click(object sender, EventArgs e)
        {
            Session["CurrentOrderType"] = "Delivery";
            Response.Redirect("OrderEntry.aspx");
        }

        protected void btnRefill_Click(object sender, EventArgs e)
        {
            Response.Redirect("RefillEntry.aspx");
        }

        protected void btnMenu_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }
            Response.Redirect("MenuManagement.aspx");
        }

        protected void btnInventory_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }
            Response.Redirect("InventoryManagement.aspx");
        }

        protected void btnReports_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }
            Response.Redirect("Reports.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        protected void btnAccounts_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }
            Response.Redirect("AccountManagement.aspx");
        }

        protected void btnTodaysOrders_Click(object sender, EventArgs e)
        {
            Response.Redirect("TodaysOrders.aspx");
        }

        protected void btnDineIn_Click(object sender, EventArgs e)
        {
            Session["CurrentOrderType"] = "Dine-in";
            Response.Redirect("OrderEntry.aspx");
        }

        protected void btnTakeOut_Click(object sender, EventArgs e)
        {
            Session["CurrentOrderType"] = "Takeout";
            Response.Redirect("OrderEntry.aspx");
        }

        protected void btnPendingOrders_Click(object sender, EventArgs e)
        {
            Response.Redirect("PendingOrders.aspx");
        }

        protected void btnQRCodes_Click(object sender, EventArgs e)
        {
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }
            Response.Redirect("QRCodeManagement.aspx");
        }

        protected void btnWalkIn_Click(object sender, EventArgs e)
        {
            Session["CurrentOrderType"] = "Dine-in";
            Response.Redirect("OrderEntry.aspx");
        }
    }
}