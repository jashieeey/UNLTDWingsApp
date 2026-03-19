using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Linq;

namespace UNLTDWingsApp
{
    public partial class GuestOrders : System.Web.UI.Page
    {
        private readonly string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            bool isGuest = Session["IsGuest"] != null && Session["IsGuest"] is bool && (bool)Session["IsGuest"]; 
            bool isTable = Session["IsTableAccount"] != null && Session["IsTableAccount"] is bool && (bool)Session["IsTableAccount"]; 

            if (!isGuest && !isTable)
            {
                Response.Redirect("GuestWelcome.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindOrders();
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("GuestMenu.aspx");
        }

        private void BindOrders()
        {
            // If we have specific Order IDs in session (for Guests without unique names yet), prioritize that
            List<int> guestOrderIDs = Session["GuestOrderIDs"] as List<int>;
            
            // If name not set yet (guest flow), show empty state with guidance.
            if (Session["GuestName"] == null && (guestOrderIDs == null || guestOrderIDs.Count == 0))
            {
                rptOrders.DataSource = null;
                rptOrders.DataBind();
                pnlEmpty.Visible = true;
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query;
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = conn;

                    if (guestOrderIDs != null && guestOrderIDs.Count > 0)
                    {
                        // Use session-tracked OrderIDs
                        // Note: String.Join is safe here as IDs are integers controlled by us
                        string idList = string.Join(",", guestOrderIDs);
                        query = $@"SELECT OrderID, OrderType, OrderDate, TotalAmount, PaymentMethod, OrderStatus
                                      FROM Orders
                                      WHERE OrderID IN ({idList})
                                      ORDER BY OrderDate DESC";
                        cmd.CommandText = query;
                    }
                    else
                    {
                        // Fallback to Name-based lookup
                        string guestName = Session["GuestName"].ToString();
                        query = @"SELECT OrderID, OrderType, OrderDate, TotalAmount, PaymentMethod, OrderStatus
                                      FROM Orders
                                      WHERE CustomerName = @Name
                                      ORDER BY OrderDate DESC";
                        cmd.CommandText = query;
                        cmd.Parameters.AddWithValue("@Name", guestName);
                    }

                    using (cmd)
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count >0)
                        {
                            rptOrders.DataSource = dt;
                            rptOrders.DataBind();
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            rptOrders.DataSource = null;
                            rptOrders.DataBind();
                            pnlEmpty.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                pnlEmpty.Visible = true;
                System.Diagnostics.Debug.WriteLine("GuestOrders error: " + ex.Message);
            }
        }

        protected string GetStatusCss(string status)
        {
            switch (status)
            {
                case "Pending": return "unltd-status-pending";
                case "Approved": return "unltd-status-approved";
                case "Completed": return "unltd-status-completed";
                case "Cancelled": return "unltd-status-cancelled";
                default: return "unltd-status-pending";
            }
        }

        protected string GetStatusBadgeCss(string status)
        {
            switch (status)
            {
                case "Pending": return "status-pending";
                case "Approved": return "status-approved";
                case "Completed": return "status-completed";
                case "Cancelled": return "status-cancelled";
                default: return "status-pending";
            }
        }

        protected string GetStatusIcon(string status)
        {
            switch (status)
            {
                case "Pending": return "bi bi-hourglass-split";
                case "Approved": return "bi bi-check-circle-fill";
                case "Completed": return "bi bi-check-all";
                case "Cancelled": return "bi bi-x-circle-fill";
                default: return "bi bi-clock";
            }
        }

        protected string GetTypeCss(string orderType)
        {
            switch (orderType)
            {
                case "Dine-in": return "type-dine-in";
                case "Delivery": return "type-delivery";
                case "Takeout":
                case "Take-out": return "type-takeout";
                default: return "type-takeout";
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            // Refresh list on every postback to reflect latest status
            if (IsPostBack)
            {
                BindOrders();
            }
        }
    }
}
