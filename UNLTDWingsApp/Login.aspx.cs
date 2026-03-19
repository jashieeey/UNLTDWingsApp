using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;

namespace UNLTDWingsApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) 
        {
       // If already logged in, redirect to appropriate page
         if (Session["UserID"] != null)
      {
          string role = (Session["Role"] ?? string.Empty).ToString();
          if (role.Equals("Guest", StringComparison.OrdinalIgnoreCase))
          {
              Response.Redirect("GuestMenu.aspx");
          }
          else
          {
              Response.Redirect("Dashboard.aspx");
          }
          return;
      }

     // Guest-only session (no UserID)
     if (Session["GuestName"] != null)
            {
      Response.Redirect("GuestMenu.aspx");
          return;
     }

            if (!IsPostBack)
     {
        // Check for "Remember Me" cookie
   CheckRememberMeCookie();
   }
        }

        private void CheckRememberMeCookie()
   {
       HttpCookie usernameCookie = Request.Cookies["UNLTD_Username"];
   HttpCookie rememberCookie = Request.Cookies["UNLTD_RememberMe"];
          
       if (usernameCookie != null && rememberCookie != null && rememberCookie.Value == "true")
 {
        txtUsername.Text = usernameCookie.Value;
           rememberMe.Checked = true;
          }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
  {
    string username = txtUsername.Text.Trim();
    string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
       {
   ShowError("Please enter username and password.");
         return;
}

    // Rate limit table logins specifically
 if (username.StartsWith("Table", StringComparison.OrdinalIgnoreCase))
 {
 if (!UNLTDWingsApp.Utilities.RateLimiter.CanLoginTable(username))
 {
 ShowError("Too many login attempts for this table. Please wait before trying again.");
 return;
 }
 }

    string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

       using (SqlConnection conn = new SqlConnection(connString))
         {
       string query = "SELECT UserID, Name, Role FROM Users WHERE Username = @User AND Password = @Pass";
         using (SqlCommand cmd = new SqlCommand(query, conn))
      {
      cmd.Parameters.AddWithValue("@User", username);
    cmd.Parameters.AddWithValue("@Pass", password);

       try
    {
           conn.Open();
     using (SqlDataReader reader = cmd.ExecuteReader())
              {
             if (reader.Read())
            {
                // Store user info in session
                Session["UserID"] = reader["UserID"].ToString();
                Session["UserName"] = reader["Name"].ToString();
                Session["Role"] = reader["Role"].ToString();

                string role = reader["Role"].ToString();

                // Table account logic: create 30-minute exclusive session
                if (username.StartsWith("Table", StringComparison.OrdinalIgnoreCase))
                {
                    string tableNumber = username.Substring(5); // Table1 ->1
                    Session["TableNumber"] = tableNumber;
                    Session["GuestName"] = "Table " + tableNumber;
                    Session["IsTableAccount"] = true;

                    // Add session expiry for table accounts (30 minutes)
                    Session.Timeout = 30;

                    TryCreateTableSession(conn, tableNumber, int.Parse(Session["UserID"].ToString()));
                }

                // Handle "Remember Me" functionality
                HandleRememberMe(username);

                // Redirect based on role
                if (role.Equals("Guest", StringComparison.OrdinalIgnoreCase))
                {
                    // Table/guest accounts should land on guest menu
                    Response.Redirect("GuestMenu.aspx");
                }
                else
                {
                    // Admin/Staff
                    Response.Redirect("Dashboard.aspx");
                }
            }
           else
       {
           ShowError("Invalid username or password.");
}
          }
                }
  catch (SqlException ex)
          {
     if (ex.Message.Contains("This table already has an active session"))
 {
 ShowError("This table is currently in an active session. Please wait for it to expire (30 minutes) or ask staff.");
 }
 else if (ex.Message.Contains("Cannot open database") || ex.Message.Contains("Login failed"))
 {
 ShowError("Database not found. Please run the DatabaseSetup.sql script first.");
 }
 else if (ex.Message.Contains("Invalid column name"))
 {
 ShowError("Database schema error. Please run the DatabaseSetup.sql script to create tables.");
 }
       else
    {
        ShowError("Database connection failed: " + ex.Message);
        }
            }
      catch (Exception ex)
        {
              ShowError("Error: " + ex.Message);
            }
       }
  }
        }

        private void HandleRememberMe(string username)
        {
            if (rememberMe.Checked)
            {
 // Create cookies that expire in 30 days
              HttpCookie usernameCookie = new HttpCookie("UNLTD_Username", username);
         usernameCookie.Expires = DateTime.Now.AddDays(30);
   usernameCookie.HttpOnly = true;
            Response.Cookies.Add(usernameCookie);

        HttpCookie rememberCookie = new HttpCookie("UNLTD_RememberMe", "true");
         rememberCookie.Expires = DateTime.Now.AddDays(30);
    rememberCookie.HttpOnly = true;
            Response.Cookies.Add(rememberCookie);
            }
         else
   {
     // Clear the cookies if "Remember Me" is not checked
            if (Request.Cookies["UNLTD_Username"] != null)
      {
   HttpCookie usernameCookie = new HttpCookie("UNLTD_Username");
    usernameCookie.Expires = DateTime.Now.AddDays(-1);
            Response.Cookies.Add(usernameCookie);
           }

    if (Request.Cookies["UNLTD_RememberMe"] != null)
           {
         HttpCookie rememberCookie = new HttpCookie("UNLTD_RememberMe");
       rememberCookie.Expires = DateTime.Now.AddDays(-1);
 Response.Cookies.Add(rememberCookie);
  }
      }
 }

    protected void btnGuest_Click(object sender, EventArgs e)
     {
   // Redirect to Guest Welcome page where they enter their name
   Response.Redirect("GuestWelcome.aspx");
        }

        private void ShowError(string message)
        {
      pnlError.Visible = true;
       lblError.Text = message;
        }

        private void TryCreateTableSession(SqlConnection conn, string tableNumber, int userId)
{
 try
 {
 // If proc doesn't exist, silently skip
 using (SqlCommand check = new SqlCommand("SELECT COUNT(*) FROM sys.objects WHERE type='P' AND name='sp_CreateTableSession'", conn))
 {
 int exists = Convert.ToInt32(check.ExecuteScalar());
 if (exists ==0) return;
 }

 using (SqlCommand proc = new SqlCommand("sp_CreateTableSession", conn))
 {
 proc.CommandType = System.Data.CommandType.StoredProcedure;
 proc.Parameters.AddWithValue("@TableNumber", tableNumber);
 proc.Parameters.AddWithValue("@UserID", userId);
 proc.ExecuteNonQuery();
 }
 }
 catch
 {
 // Let caller handle specific SQL errors; swallow others to avoid blocking login if schema not applied.
 throw;
 }
}
    }
}