using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace UNLTDWingsApp
{
 public partial class OrderDetails : System.Web.UI.Page
 {
 private readonly string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

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
 int orderId;
 int.TryParse(Request.QueryString["orderId"], out orderId);
 lblOrderId.Text = orderId.ToString();
 LoadOrder(orderId);
 }
 }

 private void LoadOrder(int orderId)
 {
 if (orderId <= 0)
 {
 pnlNotFound.Visible = true;
 pnlDetails.Visible = false;
 pnlItems.Visible = false;
 return;
 }

 using (SqlConnection conn = new SqlConnection(connString))
 {
 conn.Open();

 string q = @"
SELECT OrderID, CustomerName, OrderType, TableNumber, Address, ContactNumber, PaymentMethod, ReferenceNumber, OrderStatus, OrderDate, TotalAmount
FROM Orders
WHERE OrderID = @OrderID";

 using (SqlCommand cmd = new SqlCommand(q, conn))
 {
 cmd.Parameters.AddWithValue("@OrderID", orderId);
 using (SqlDataReader r = cmd.ExecuteReader())
 {
 if (!r.Read())
 {
 pnlNotFound.Visible = true;
 pnlDetails.Visible = false;
 pnlItems.Visible = false;
 return;
 }

 pnlNotFound.Visible = false;
 pnlDetails.Visible = true;

 lblCustomer.Text = Convert.ToString(r["CustomerName"]);
 lblType.Text = Convert.ToString(r["OrderType"]);
 lblTable.Text = r["TableNumber"] == DBNull.Value || string.IsNullOrEmpty(r["TableNumber"].ToString()) ? "-" : Convert.ToString(r["TableNumber"]);
 lblAddress.Text = r["Address"] == DBNull.Value || string.IsNullOrEmpty(r["Address"].ToString()) ? "-" : Convert.ToString(r["Address"]);
 lblContact.Text = r["ContactNumber"] == DBNull.Value || string.IsNullOrEmpty(r["ContactNumber"].ToString()) ? "-" : Convert.ToString(r["ContactNumber"]);
 lblPayment.Text = r["PaymentMethod"] == DBNull.Value || string.IsNullOrEmpty(r["PaymentMethod"].ToString()) ? "-" : Convert.ToString(r["PaymentMethod"]);
 lblRef.Text = r["ReferenceNumber"] == DBNull.Value || string.IsNullOrEmpty(r["ReferenceNumber"].ToString()) ? "-" : Convert.ToString(r["ReferenceNumber"]);
 lblStatus.Text = Convert.ToString(r["OrderStatus"]);
 lblDate.Text = Convert.ToDateTime(r["OrderDate"]).ToString("MMM dd, yyyy hh:mm tt");
 lblTotal.Text = Convert.ToDecimal(r["TotalAmount"]).ToString("N2");
 }
 }

 string items = @"
SELECT m.ItemName, oi.Quantity, oi.Subtotal
FROM Order_Item oi
INNER JOIN Menu_Item m ON oi.ItemID = m.ItemID
WHERE oi.OrderID = @OrderID
ORDER BY oi.ItemSequence";

 DataTable dt = new DataTable();
 using (SqlCommand cmd = new SqlCommand(items, conn))
 {
 cmd.Parameters.AddWithValue("@OrderID", orderId);
 SqlDataAdapter da = new SqlDataAdapter(cmd);
 da.Fill(dt);
 }

 gvItems.DataSource = dt;
 gvItems.DataBind();
 pnlItems.Visible = true;
 }
 }
 }
}
