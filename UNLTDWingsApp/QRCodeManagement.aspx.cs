using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class QRCodeManagement : System.Web.UI.Page
    {
string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
         // Check if user is admin
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
   EnsureTableExists();
        LoadQRCodes();
            }
    }

 private void EnsureTableExists()
        {
      try
        {
       using (SqlConnection conn = new SqlConnection(connString))
     {
      conn.Open();
         
     // Check if table exists, if not create it
        string checkTable = @"IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TableQRCodes' AND xtype='U')
   BEGIN
          CREATE TABLE TableQRCodes (
          QRCodeID INT PRIMARY KEY IDENTITY(1,1),
           TableNumber NVARCHAR(10) NOT NULL,
         TableDescription NVARCHAR(100) NULL,
         OrderUrl NVARCHAR(500) NOT NULL,
       QRImageUrl NVARCHAR(500) NULL,
    IsActive BIT DEFAULT 1,
               CreatedDate DATETIME DEFAULT GETDATE(),
               LastModified DATETIME DEFAULT GETDATE()
          );
      END";
        
             using (SqlCommand cmd = new SqlCommand(checkTable, conn))
     {
             cmd.ExecuteNonQuery();
        }
      }
        }
  catch (Exception ex)
            {
     ShowMessage("Error initializing: " + ex.Message, false);
    }
     }

        protected void btnBack_Click(object sender, EventArgs e)
        {
   Response.Redirect("Dashboard.aspx");
     }

protected void btnShowAdd_Click(object sender, EventArgs e)
        {
            ClearForm();
        lblFormTitle.Text = "Add New Table QR Code";
            pnlForm.Visible = true;
        }

        protected void btnCancelForm_Click(object sender, EventArgs e)
        {
        pnlForm.Visible = false;
            ClearForm();
      }

   private void ClearForm()
        {
        hfQRCodeID.Value = "0";
       txtTableNumber.Text = "";
   txtTableDescription.Text = "";
            txtCustomUrl.Text = "";
        chkActive.Checked = true;
        }

        private void LoadQRCodes()
        {
            try
            {
             using (SqlConnection conn = new SqlConnection(connString))
                {
              string query = "SELECT * FROM TableQRCodes ORDER BY TableNumber";
    using (SqlCommand cmd = new SqlCommand(query, conn))
       {
              SqlDataAdapter da = new SqlDataAdapter(cmd);
       DataTable dt = new DataTable();
    da.Fill(dt);

             lblQRCount.Text = dt.Rows.Count.ToString();

    if (dt.Rows.Count > 0)
   {
 rptQRCodes.DataSource = dt;
                rptQRCodes.DataBind();
         pnlNoQRCodes.Visible = false;
      }
  else
            {
   rptQRCodes.DataSource = null;
               rptQRCodes.DataBind();
          pnlNoQRCodes.Visible = true;
   }
        }
       }
            }
      catch (Exception ex)
    {
          ShowMessage("Error loading QR codes: " + ex.Message, false);
  }
   }

        protected void btnSave_Click(object sender, EventArgs e)
        {
       if (string.IsNullOrWhiteSpace(txtTableNumber.Text))
            {
 ShowMessage("Please enter a table number.", false);
             return;
          }

  try
            {
    using (SqlConnection conn = new SqlConnection(connString))
       {
        conn.Open();
      int qrCodeId = int.Parse(hfQRCodeID.Value);
     
     // Generate the order URL for this table
        string baseUrl = Request.Url.GetLeftPart(UriPartial.Authority) + Request.ApplicationPath;
  if (!baseUrl.EndsWith("/")) baseUrl += "/";
         string orderUrl = baseUrl + "GuestWelcome.aspx?table=" + Server.UrlEncode(txtTableNumber.Text.Trim());

   if (qrCodeId == 0)
       {
     // Check if table number already exists
            string checkQuery = "SELECT COUNT(*) FROM TableQRCodes WHERE TableNumber = @TableNumber";
      using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                {
             checkCmd.Parameters.AddWithValue("@TableNumber", txtTableNumber.Text.Trim());
          int count = (int)checkCmd.ExecuteScalar();
 if (count > 0)
  {
      ShowMessage("A QR code for this table number already exists.", false);
      return;
       }
    }

      // Insert new QR code
   string query = @"INSERT INTO TableQRCodes (TableNumber, TableDescription, OrderUrl, QRImageUrl, IsActive) 
             VALUES (@TableNumber, @Description, @OrderUrl, @QRImageUrl, @IsActive)";
          using (SqlCommand cmd = new SqlCommand(query, conn))
    {
            cmd.Parameters.AddWithValue("@TableNumber", txtTableNumber.Text.Trim());
        cmd.Parameters.AddWithValue("@Description", txtTableDescription.Text.Trim());
       cmd.Parameters.AddWithValue("@OrderUrl", orderUrl);
             cmd.Parameters.AddWithValue("@QRImageUrl", string.IsNullOrWhiteSpace(txtCustomUrl.Text) ? (object)DBNull.Value : txtCustomUrl.Text.Trim());
      cmd.Parameters.AddWithValue("@IsActive", chkActive.Checked);
   cmd.ExecuteNonQuery();
            }
 ShowMessage("Table QR code added successfully!", true);
     }
           else
          {
           // Update existing QR code
              string query = @"UPDATE TableQRCodes SET 
            TableNumber = @TableNumber, 
            TableDescription = @Description, 
    OrderUrl = @OrderUrl,
         QRImageUrl = @QRImageUrl, 
        IsActive = @IsActive,
      LastModified = GETDATE()
WHERE QRCodeID = @ID";
     using (SqlCommand cmd = new SqlCommand(query, conn))
  {
        cmd.Parameters.AddWithValue("@ID", qrCodeId);
   cmd.Parameters.AddWithValue("@TableNumber", txtTableNumber.Text.Trim());
     cmd.Parameters.AddWithValue("@Description", txtTableDescription.Text.Trim());
                 cmd.Parameters.AddWithValue("@OrderUrl", orderUrl);
      cmd.Parameters.AddWithValue("@QRImageUrl", string.IsNullOrWhiteSpace(txtCustomUrl.Text) ? (object)DBNull.Value : txtCustomUrl.Text.Trim());
   cmd.Parameters.AddWithValue("@IsActive", chkActive.Checked);
 cmd.ExecuteNonQuery();
  }
              ShowMessage("Table QR code updated successfully!", true);
                }

      pnlForm.Visible = false;
     ClearForm();
    LoadQRCodes();
        }
            }
            catch (Exception ex)
        {
     ShowMessage("Error saving QR code: " + ex.Message, false);
     }
   }

        protected void rptQRCodes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
  if (e.CommandName == "Edit")
            {
    int qrCodeId = int.Parse(e.CommandArgument.ToString());
           LoadQRCodeForEdit(qrCodeId);
            }
            else if (e.CommandName == "Toggle")
            {
      string[] args = e.CommandArgument.ToString().Split('|');
            int qrCodeId = int.Parse(args[0]);
       bool currentStatus = bool.Parse(args[1]);
    ToggleQRCodeStatus(qrCodeId, !currentStatus);
      }
            else if (e.CommandName == "Delete")
          {
            int qrCodeId = int.Parse(e.CommandArgument.ToString());
           DeleteQRCode(qrCodeId);
   }
        }

        private void LoadQRCodeForEdit(int qrCodeId)
        {
      try
          {
     using (SqlConnection conn = new SqlConnection(connString))
     {
     string query = "SELECT * FROM TableQRCodes WHERE QRCodeID = @ID";
               using (SqlCommand cmd = new SqlCommand(query, conn))
 {
           cmd.Parameters.AddWithValue("@ID", qrCodeId);
      conn.Open();
     using (SqlDataReader reader = cmd.ExecuteReader())
         {
       if (reader.Read())
 {
            hfQRCodeID.Value = qrCodeId.ToString();
    txtTableNumber.Text = reader["TableNumber"].ToString();
       txtTableDescription.Text = reader["TableDescription"].ToString();
     txtCustomUrl.Text = reader["QRImageUrl"]?.ToString() ?? "";
   chkActive.Checked = Convert.ToBoolean(reader["IsActive"]);

         lblFormTitle.Text = "Edit Table QR Code";
             pnlForm.Visible = true;
    }
    }
             }
     }
       }
            catch (Exception ex)
        {
   ShowMessage("Error loading QR code: " + ex.Message, false);
            }
        }

        private void ToggleQRCodeStatus(int qrCodeId, bool newStatus)
        {
      try
        {
                using (SqlConnection conn = new SqlConnection(connString))
          {
            string query = "UPDATE TableQRCodes SET IsActive = @Status, LastModified = GETDATE() WHERE QRCodeID = @ID";
  using (SqlCommand cmd = new SqlCommand(query, conn))
       {
            cmd.Parameters.AddWithValue("@ID", qrCodeId);
          cmd.Parameters.AddWithValue("@Status", newStatus);
                conn.Open();
      cmd.ExecuteNonQuery();
         }
      }
          ShowMessage(newStatus ? "QR code activated!" : "QR code deactivated!", true);
  LoadQRCodes();
  }
            catch (Exception ex)
       {
       ShowMessage("Error updating status: " + ex.Message, false);
      }
        }

   private void DeleteQRCode(int qrCodeId)
    {
            try
        {
     using (SqlConnection conn = new SqlConnection(connString))
      {
                string query = "DELETE FROM TableQRCodes WHERE QRCodeID = @ID";
        using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
         cmd.Parameters.AddWithValue("@ID", qrCodeId);
      conn.Open();
      cmd.ExecuteNonQuery();
     }
  }
                ShowMessage("QR code deleted successfully!", true);
    LoadQRCodes();
      }
      catch (Exception ex)
   {
      ShowMessage("Error deleting QR code: " + ex.Message, false);
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
