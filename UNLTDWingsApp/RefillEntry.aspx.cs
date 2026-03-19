using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace UNLTDWingsApp
{
    public partial class RefillEntry : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Only staff/admin can log refills
            string role = (Session["Role"] ?? string.Empty).ToString();
            if (!role.Equals("Staff", StringComparison.OrdinalIgnoreCase) && !role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadActiveOrders();
                LoadRecentRefills();
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("Dashboard.aspx");
        }

        private void LoadActiveOrders()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Only APPROVED dine-in orders that contain at least one Unlimited item are eligible for refills
                    string query = @"SELECT DISTINCT o.OrderID,
    CONCAT('Order #', o.OrderID, ' - ', ISNULL(o.CustomerName, 'Guest'),
       CASE WHEN o.TableNumber IS NOT NULL THEN ' (Table ' + o.TableNumber + ')' ELSE '' END) AS DisplayText
  FROM Orders o
 INNER JOIN Order_Item oi ON o.OrderID = oi.OrderID
 INNER JOIN Menu_Item mi ON oi.ItemID = mi.ItemID
 WHERE CAST(o.OrderDate AS DATE) = CAST(GETDATE() AS DATE)
   AND o.OrderStatus IN ('Approved', 'Completed')
   AND o.OrderType = 'Dine-in'
   AND mi.ItemCategory = 'Unlimited'
 ORDER BY o.OrderID DESC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        ddlOrders.DataSource = cmd.ExecuteReader();
                        ddlOrders.DataTextField = "DisplayText";
                        ddlOrders.DataValueField = "OrderID";
                        ddlOrders.DataBind();

                        if (ddlOrders.Items.Count == 0)
                        {
                            ddlOrders.Items.Add(new System.Web.UI.WebControls.ListItem("No eligible dine-in unlimited orders today", "0"));
                            btnLogRefill.Enabled = false;
                        }
                        else
                        {
                            btnLogRefill.Enabled = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading eligible orders: " + ex.Message, false);
            }
        }

        protected void btnLogRefill_Click(object sender, EventArgs e)
        {
            if (ddlOrders.Items.Count == 0 || ddlOrders.SelectedValue == "0")
            {
                ShowMessage("No active orders available today.", false);
                return;
            }

            int orderId = int.Parse(ddlOrders.SelectedValue);
            string flavor = hfSelectedFlavor.Value;
            int quantity;

            if (!int.TryParse(txtQuantity.Text, out quantity) || quantity < 1)
            {
                ShowMessage("Please enter a valid quantity.", false);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Defense in depth: re-check eligibility server-side
                    string eligibleQuery = @"SELECT COUNT(1)
FROM Orders o
INNER JOIN Order_Item oi ON o.OrderID = oi.OrderID
INNER JOIN Menu_Item mi ON oi.ItemID = mi.ItemID
WHERE o.OrderID = @OrderID
 AND CAST(o.OrderDate AS DATE) = CAST(GETDATE() AS DATE)
 AND o.OrderStatus IN ('Approved','Completed')
 AND o.OrderType = 'Dine-in'
 AND mi.ItemCategory = 'Unlimited'";
                    using (SqlCommand check = new SqlCommand(eligibleQuery, conn))
                    {
                        check.Parameters.AddWithValue("@OrderID", orderId);
                        int ok = Convert.ToInt32(check.ExecuteScalar());
                        if (ok <= 0)
                        {
                            ShowMessage("Selected order is not eligible for unlimited refills.", false);
                            LoadActiveOrders();
                            return;
                        }
                    }

                    SqlTransaction transaction = conn.BeginTransaction();

                    try
                    {
                        // Get the user ID for logging
                        int loggedBy = int.Parse(Session["UserID"].ToString());

                        // 1. Insert the Refill Log
                        string insertQuery = @"INSERT INTO Refill_Log (OrderID, RefillNumber, Flavor, QuantityDeducted, LoggedBy) 
 VALUES (@OrderID, 0, @Flavor, @Qty, @LoggedBy)";
                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", orderId);
                            cmd.Parameters.AddWithValue("@Flavor", flavor);
                            cmd.Parameters.AddWithValue("@Qty", quantity);
                            cmd.Parameters.AddWithValue("@LoggedBy", loggedBy);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Deduct from Inventory (Chicken Wings)
                        string updateQuery = "UPDATE Inventory SET StockLevel = StockLevel - @Qty, LastUpdated = GETDATE() WHERE IngredientName = 'Chicken Wings'";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@Qty", quantity);
                            cmd.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        ShowMessage($"Refill logged! {quantity} {flavor} wings deducted from stock.", true);
                        LoadRecentRefills();
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        ShowMessage("Error: " + ex.Message, false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Database Error: " + ex.Message, false);
            }
        }

        private void LoadRecentRefills()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"SELECT TOP 10 
       ISNULL(o.CustomerName, 'Guest') AS CustomerName, 
    r.Flavor, 
        r.QuantityDeducted AS Quantity, 
        r.RefillTime 
               FROM Refill_Log r
   INNER JOIN Orders o ON r.OrderID = o.OrderID
            WHERE CAST(r.RefillTime AS DATE) = CAST(GETDATE() AS DATE)
       ORDER BY r.RefillTime DESC";
                    SqlDataAdapter da = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptRefills.DataSource = dt;
                        rptRefills.DataBind();
                        pnlNoRefills.Visible = false;
                    }
                    else
                    {
                        rptRefills.DataSource = null;
                        rptRefills.DataBind();
                        pnlNoRefills.Visible = true;
                    }
                }
            }
            catch (Exception)
            {
                pnlNoRefills.Visible = true;
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "message success" : "message error";
            lblMessage.Visible = true;
        }
    }
}