using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace UNLTDWingsApp
{
    public partial class Reports : System.Web.UI.Page
 {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
        if (Session["UserID"] == null)
  {
          Response.Redirect("Login.aspx");
       return;
     }

    string role = Session["Role"]?.ToString() ?? "";
 if (!role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
    {
      Response.Redirect("Dashboard.aspx");
     return;
       }

  if (!IsPostBack)
      {
 // Set default date range (last 30 days)
   txtStartDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
      txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
      LoadQuickStats();
      }
   }

        protected void btnBack_Click(object sender, EventArgs e)
        {
  Response.Redirect("Dashboard.aspx");
        }

        private void LoadQuickStats()
  {
          try
     {
         using (SqlConnection conn = new SqlConnection(connString))
     {
 conn.Open();

     // Today's sales
         using (SqlCommand cmd = new SqlCommand(@"SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders 
   WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE) AND PaymentStatus = 'Paid'", conn))
         {
          decimal todaySales = Convert.ToDecimal(cmd.ExecuteScalar());
       lblTodaySales.Text = "?" + todaySales.ToString("N0");
     }

    // Today's orders
  using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(*) FROM Orders 
 WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
      {
          lblTodayOrders.Text = cmd.ExecuteScalar().ToString();
      }

            // This week's sales
  using (SqlCommand cmd = new SqlCommand(@"SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders 
       WHERE OrderDate >= DATEADD(DAY, -7, GETDATE()) AND PaymentStatus = 'Paid'", conn))
      {
  decimal weekSales = Convert.ToDecimal(cmd.ExecuteScalar());
 lblWeekSales.Text = "?" + weekSales.ToString("N0");
            }

      // This month's sales
              using (SqlCommand cmd = new SqlCommand(@"SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders 
        WHERE MONTH(OrderDate) = MONTH(GETDATE()) AND YEAR(OrderDate) = YEAR(GETDATE()) AND PaymentStatus = 'Paid'", conn))
           {
           decimal monthSales = Convert.ToDecimal(cmd.ExecuteScalar());
         lblMonthSales.Text = "?" + monthSales.ToString("N0");
  }
     }
            }
   catch { }
    }

 protected void btnGenerate_Click(object sender, EventArgs e)
     {
         DateTime startDate, endDate;
            
      if (!DateTime.TryParse(txtStartDate.Text, out startDate) || 
          !DateTime.TryParse(txtEndDate.Text, out endDate))
 {
           return;
            }

if (startDate > endDate)
            {
     return;
            }

            try
   {
             using (SqlConnection conn = new SqlConnection(connString))
       {
   conn.Open();

    // Total Sales
      using (SqlCommand cmd = new SqlCommand(@"SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders 
              WHERE OrderDate >= @Start AND OrderDate < DATEADD(DAY, 1, @End) AND PaymentStatus = 'Paid'", conn))
 {
   cmd.Parameters.AddWithValue("@Start", startDate);
   cmd.Parameters.AddWithValue("@End", endDate);
      decimal totalSales = Convert.ToDecimal(cmd.ExecuteScalar());
       lblTotalSales.Text = totalSales.ToString("N0");
        }

        // Total Orders
           int totalOrders = 0;
          using (SqlCommand cmd = new SqlCommand(@"SELECT COUNT(*) FROM Orders 
       WHERE OrderDate >= @Start AND OrderDate < DATEADD(DAY, 1, @End)", conn))
   {
       cmd.Parameters.AddWithValue("@Start", startDate);
      cmd.Parameters.AddWithValue("@End", endDate);
 totalOrders = (int)cmd.ExecuteScalar();
       lblTotalOrders.Text = totalOrders.ToString();
   }

           // Average Order Value
      using (SqlCommand cmd = new SqlCommand(@"SELECT ISNULL(AVG(TotalAmount), 0) FROM Orders 
               WHERE OrderDate >= @Start AND OrderDate < DATEADD(DAY, 1, @End) AND PaymentStatus = 'Paid'", conn))
    {
   cmd.Parameters.AddWithValue("@Start", startDate);
     cmd.Parameters.AddWithValue("@End", endDate);
     decimal avgOrder = Convert.ToDecimal(cmd.ExecuteScalar());
        lblAvgOrder.Text = avgOrder.ToString("N0");
}

         // Top Selling Items
   string topQuery = @"SELECT TOP 5 m.ItemName, SUM(oi.Quantity) AS TotalQty
           FROM Order_Item oi
        INNER JOIN Menu_Item m ON oi.ItemID = m.ItemID
            INNER JOIN Orders o ON oi.OrderID = o.OrderID
         WHERE o.OrderDate >= @Start AND o.OrderDate < DATEADD(DAY, 1, @End)
     GROUP BY m.ItemName
               ORDER BY TotalQty DESC";
        using (SqlCommand cmd = new SqlCommand(topQuery, conn))
            {
  cmd.Parameters.AddWithValue("@Start", startDate);
   cmd.Parameters.AddWithValue("@End", endDate);
      SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
          da.Fill(dt);
          rptTopItems.DataSource = dt;
                rptTopItems.DataBind();
          }

        // Orders List
     string ordersQuery = @"SELECT OrderID, OrderDate, CustomerName, OrderType, PaymentMethod, PaymentStatus, TotalAmount
             FROM Orders
           WHERE OrderDate >= @Start AND OrderDate < DATEADD(DAY, 1, @End)
      ORDER BY OrderDate DESC";
    using (SqlCommand cmd = new SqlCommand(ordersQuery, conn))
         {
         cmd.Parameters.AddWithValue("@Start", startDate);
    cmd.Parameters.AddWithValue("@End", endDate);
           SqlDataAdapter da = new SqlDataAdapter(cmd);
        DataTable dt = new DataTable();
    da.Fill(dt);
        rptOrders.DataSource = dt;
     rptOrders.DataBind();
              }
}

             pnlReport.Visible = true;
      }
            catch { }
        }

      protected string GetRankClass(int index)
        {
    switch (index)
 {
          case 0: return "top-rank gold";
      case 1: return "top-rank silver";
case 2: return "top-rank bronze";
         default: return "top-rank";
            }
    }
    }
}
