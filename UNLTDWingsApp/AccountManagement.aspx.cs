using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class AccountManagement : System.Web.UI.Page
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
                LoadUsers();
   }
        }

        protected void btnBack_Click(object sender, EventArgs e)
 {
      Response.Redirect("Dashboard.aspx");
        }

        protected void btnShowAdd_Click(object sender, EventArgs e)
 {
      ClearForm();
         lblFormTitle.Text = "Add New User";
       lblPasswordNote.Text = "*";
   pnlForm.Visible = true;
        }

        protected void btnCancelForm_Click(object sender, EventArgs e)
        {
            pnlForm.Visible = false;
   ClearForm();
        }

    private void ClearForm()
        {
            hfUserID.Value = "0";
            txtName.Text = "";
 txtUsername.Text = "";
            txtPassword.Text = "";
            ddlRole.SelectedIndex = 0;
}

        private void LoadUsers()
        {
            try
   {
   using (SqlConnection conn = new SqlConnection(connString))
           {
   string query = "SELECT UserID, Username, Name, Role FROM Users ORDER BY Role, Name";
   SqlDataAdapter da = new SqlDataAdapter(query, conn);
         DataTable dt = new DataTable();
      da.Fill(dt);

      lblUserCount.Text = dt.Rows.Count.ToString();

     if (dt.Rows.Count > 0)
  {
              rptUsers.DataSource = dt;
         rptUsers.DataBind();
       pnlNoUsers.Visible = false;
     }
 else
    {
           rptUsers.DataSource = null;
         rptUsers.DataBind();
        pnlNoUsers.Visible = true;
            }
 }
   }
         catch (Exception ex)
          {
  ShowMessage("Error loading users: " + ex.Message, false);
      }
}

     protected void btnSave_Click(object sender, EventArgs e)
        {
        if (string.IsNullOrWhiteSpace(txtName.Text) || string.IsNullOrWhiteSpace(txtUsername.Text))
        {
                ShowMessage("Please fill in all required fields.", false);
       return;
        }

 int userId = int.Parse(hfUserID.Value);

  // Password validation
     if (userId == 0 && string.IsNullOrWhiteSpace(txtPassword.Text))
            {
          ShowMessage("Password is required for new users.", false);
   return;
    }

  if (!string.IsNullOrWhiteSpace(txtPassword.Text) && txtPassword.Text.Length < 8)
            {
          ShowMessage("Password must be at least 8 characters.", false);
       return;
    }

            try
      {
                using (SqlConnection conn = new SqlConnection(connString))
       {
            conn.Open();

   // Check for duplicate username
           string checkQuery = "SELECT COUNT(*) FROM Users WHERE Username = @Username AND UserID != @ID";
      using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
    {
  cmd.Parameters.AddWithValue("@Username", txtUsername.Text.Trim());
   cmd.Parameters.AddWithValue("@ID", userId);
   int count = (int)cmd.ExecuteScalar();
     if (count > 0)
            {
     ShowMessage("Username already exists. Please choose a different one.", false);
      return;
        }
 }

 if (userId == 0)
         {
        // Insert new user
     string query = @"INSERT INTO Users (Username, Password, Name, Role) 
     VALUES (@Username, @Password, @Name, @Role)";
               using (SqlCommand cmd = new SqlCommand(query, conn))
 {
      cmd.Parameters.AddWithValue("@Username", txtUsername.Text.Trim());
  cmd.Parameters.AddWithValue("@Password", txtPassword.Text);
       cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
               cmd.Parameters.AddWithValue("@Role", ddlRole.SelectedValue);
           cmd.ExecuteNonQuery();
        }
       ShowMessage("User added successfully!", true);
       }
         else
      {
          // Update existing user
     string query;
           if (!string.IsNullOrWhiteSpace(txtPassword.Text))
     {
     query = @"UPDATE Users SET Username = @Username, Password = @Password, 
           Name = @Name, Role = @Role WHERE UserID = @ID";
   }
 else
        {
          query = @"UPDATE Users SET Username = @Username, Name = @Name, 
    Role = @Role WHERE UserID = @ID";
            }

     using (SqlCommand cmd = new SqlCommand(query, conn))
     {
         cmd.Parameters.AddWithValue("@ID", userId);
         cmd.Parameters.AddWithValue("@Username", txtUsername.Text.Trim());
           cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
     cmd.Parameters.AddWithValue("@Role", ddlRole.SelectedValue);
  if (!string.IsNullOrWhiteSpace(txtPassword.Text))
          {
              cmd.Parameters.AddWithValue("@Password", txtPassword.Text);
  }
        cmd.ExecuteNonQuery();
             }
  ShowMessage("User updated successfully!", true);
      }

        pnlForm.Visible = false;
      ClearForm();
             LoadUsers();
  }
            }
            catch (Exception ex)
      {
         ShowMessage("Error saving user: " + ex.Message, false);
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
  int userId = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Edit")
            {
       LoadUserForEdit(userId);
 }
            else if (e.CommandName == "Delete")
            {
           DeleteUser(userId);
            }
        }

        private void LoadUserForEdit(int userId)
        {
       try
          {
      using (SqlConnection conn = new SqlConnection(connString))
     {
         string query = "SELECT * FROM Users WHERE UserID = @ID";
using (SqlCommand cmd = new SqlCommand(query, conn))
        {
      cmd.Parameters.AddWithValue("@ID", userId);
       conn.Open();
     using (SqlDataReader reader = cmd.ExecuteReader())
  {
       if (reader.Read())
 {
     hfUserID.Value = userId.ToString();
         txtName.Text = reader["Name"].ToString();
  txtUsername.Text = reader["Username"].ToString();
     txtPassword.Text = ""; // Don't show existing password
          ddlRole.SelectedValue = reader["Role"].ToString();

     lblFormTitle.Text = "Edit User";
       lblPasswordNote.Text = "(leave blank to keep current)";
            pnlForm.Visible = true;
       }
        }
        }
        }
     }
            catch (Exception ex)
  {
      ShowMessage("Error loading user: " + ex.Message, false);
            }
        }

        private void DeleteUser(int userId)
{
    // Prevent deleting yourself
            if (userId.ToString() == Session["UserID"]?.ToString())
            {
     ShowMessage("You cannot delete your own account.", false);
         return;
       }

          try
            {
      using (SqlConnection conn = new SqlConnection(connString))
                {
         string query = "DELETE FROM Users WHERE UserID = @ID";
      using (SqlCommand cmd = new SqlCommand(query, conn))
          {
       cmd.Parameters.AddWithValue("@ID", userId);
   conn.Open();
   cmd.ExecuteNonQuery();
        }

                ShowMessage("User deleted successfully!", true);
       LoadUsers();
         }
 }
            catch (Exception ex)
{
          ShowMessage("Error deleting user: " + ex.Message, false);
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
