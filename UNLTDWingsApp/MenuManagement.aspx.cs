using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class MenuManagement : System.Web.UI.Page
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
      LoadMenuItems("All");
         }
 }

        protected void btnBack_Click(object sender, EventArgs e)
{
            Response.Redirect("Dashboard.aspx");
      }

        protected void btnShowAdd_Click(object sender, EventArgs e)
        {
 ClearForm();
     lblFormTitle.Text = "Add New Menu Item";
         pnlForm.Visible = true;
        }

        protected void btnCancelForm_Click(object sender, EventArgs e)
        {
      pnlForm.Visible = false;
    ClearForm();
        }

        private void ClearForm()
  {
            hfItemID.Value = "0";
   txtItemName.Text = "";
         txtDescription.Text = "";
 ddlCategory.SelectedIndex = 0;
            txtPrice.Text = "";
         chkAvailable.Checked = true;
      }

        private void LoadMenuItems(string category)
  {
            try
 {
        using (SqlConnection conn = new SqlConnection(connString))
     {
string query = "SELECT ItemID, ItemName, ItemDescription, ItemCategory, Price, IsAvailable FROM Menu_Item";
               if (category != "All")
           {
  query += " WHERE ItemCategory = @Category";
       }
query += " ORDER BY ItemCategory, ItemName";

       using (SqlCommand cmd = new SqlCommand(query, conn))
           {
   if (category != "All")
   {
           cmd.Parameters.AddWithValue("@Category", category);
  }

           SqlDataAdapter da = new SqlDataAdapter(cmd);
  DataTable dt = new DataTable();
      da.Fill(dt);

                lblItemCount.Text = dt.Rows.Count.ToString();

      if (dt.Rows.Count > 0)
      {
   rptMenuItems.DataSource = dt;
      rptMenuItems.DataBind();
                     pnlNoItems.Visible = false;
         }
    else
       {
       rptMenuItems.DataSource = null;
       rptMenuItems.DataBind();
       pnlNoItems.Visible = true;
   }
                 }
             }
     }
  catch (Exception ex)
            {
         ShowMessage("Error loading menu items: " + ex.Message, false);
    }
        }

   protected void btnFilter_Click(object sender, EventArgs e)
{
     LinkButton btn = (LinkButton)sender;
    string category = btn.CommandArgument;

 // Reset all filter button styles
    btnFilterAll.CssClass = "filter-btn";
          btnFilterUnlimited.CssClass = "filter-btn";
   btnFilterWings.CssClass = "filter-btn";
   btnFilterRice.CssClass = "filter-btn";
       btnFilterPasta.CssClass = "filter-btn";
   btnFilterCombos.CssClass = "filter-btn";
          btnFilterFries.CssClass = "filter-btn";
        btnFilterDrinks.CssClass = "filter-btn";
   btnFilterAddons.CssClass = "filter-btn";

            btn.CssClass = "filter-btn active";
 LoadMenuItems(category);
}

        protected void btnSave_Click(object sender, EventArgs e)
        {
 if (string.IsNullOrWhiteSpace(txtItemName.Text) || string.IsNullOrWhiteSpace(txtPrice.Text))
   {
            ShowMessage("Please fill in all required fields.", false);
   return;
            }

            decimal price;
            if (!decimal.TryParse(txtPrice.Text, out price) || price <= 0)
   {
                ShowMessage("Please enter a valid price.", false);
  return;
 }

try
            {
    using (SqlConnection conn = new SqlConnection(connString))
    {
     conn.Open();
         int itemId = int.Parse(hfItemID.Value);

              if (itemId == 0)
    {
       // Insert new item
      string query = @"INSERT INTO Menu_Item (ItemName, ItemDescription, ItemCategory, Price, IsAvailable) 
          VALUES (@Name, @Desc, @Cat, @Price, @Available)";
    using (SqlCommand cmd = new SqlCommand(query, conn))
      {
   cmd.Parameters.AddWithValue("@Name", txtItemName.Text.Trim());
           cmd.Parameters.AddWithValue("@Desc", txtDescription.Text.Trim());
     cmd.Parameters.AddWithValue("@Cat", ddlCategory.SelectedValue);
  cmd.Parameters.AddWithValue("@Price", price);
           cmd.Parameters.AddWithValue("@Available", chkAvailable.Checked);
       cmd.ExecuteNonQuery();
             }
     ShowMessage("Menu item added successfully!", true);
        }
           else
    {
    // Update existing item
       string query = @"UPDATE Menu_Item SET ItemName = @Name, ItemDescription = @Desc, 
     ItemCategory = @Cat, Price = @Price, IsAvailable = @Available 
     WHERE ItemID = @ID";
         using (SqlCommand cmd = new SqlCommand(query, conn))
     {
      cmd.Parameters.AddWithValue("@ID", itemId);
         cmd.Parameters.AddWithValue("@Name", txtItemName.Text.Trim());
     cmd.Parameters.AddWithValue("@Desc", txtDescription.Text.Trim());
        cmd.Parameters.AddWithValue("@Cat", ddlCategory.SelectedValue);
          cmd.Parameters.AddWithValue("@Price", price);
             cmd.Parameters.AddWithValue("@Available", chkAvailable.Checked);
      cmd.ExecuteNonQuery();
     }
          ShowMessage("Menu item updated successfully!", true);
   }

        pnlForm.Visible = false;
         ClearForm();
        LoadMenuItems("All");
                }
 }
        catch (Exception ex)
{
          ShowMessage("Error saving menu item: " + ex.Message, false);
        }
        }

        protected void rptMenuItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int itemId = int.Parse(e.CommandArgument.ToString());

if (e.CommandName == "Edit")
  {
    LoadItemForEdit(itemId);
 }
      else if (e.CommandName == "Delete")
       {
  DeleteItem(itemId);
       }
        }

   private void LoadItemForEdit(int itemId)
        {
            try
            {
         using (SqlConnection conn = new SqlConnection(connString))
   {
            string query = "SELECT * FROM Menu_Item WHERE ItemID = @ID";
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
      cmd.Parameters.AddWithValue("@ID", itemId);
  conn.Open();
 using (SqlDataReader reader = cmd.ExecuteReader())
       {
          if (reader.Read())
          {
  hfItemID.Value = itemId.ToString();
   txtItemName.Text = reader["ItemName"].ToString();
  txtDescription.Text = reader["ItemDescription"].ToString();
     ddlCategory.SelectedValue = reader["ItemCategory"].ToString();
     txtPrice.Text = Convert.ToDecimal(reader["Price"]).ToString("0.00");
                chkAvailable.Checked = Convert.ToBoolean(reader["IsAvailable"]);

       lblFormTitle.Text = "Edit Menu Item";
                  pnlForm.Visible = true;
        }
   }
          }
          }
}
     catch (Exception ex)
            {
  ShowMessage("Error loading item: " + ex.Message, false);
         }
     }

    private void DeleteItem(int itemId)
        {
            try
   {
   using (SqlConnection conn = new SqlConnection(connString))
          {
       // Check if item is used in any orders
  string checkQuery = "SELECT COUNT(*) FROM Order_Item WHERE ItemID = @ID";
        using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
       {
            cmd.Parameters.AddWithValue("@ID", itemId);
             conn.Open();
   int count = (int)cmd.ExecuteScalar();
           if (count > 0)
             {
           ShowMessage("Cannot delete this item because it has been used in orders. Consider marking it as unavailable instead.", false);
         return;
    }
    }

              string query = "DELETE FROM Menu_Item WHERE ItemID = @ID";
     using (SqlCommand cmd = new SqlCommand(query, conn))
      {
     cmd.Parameters.AddWithValue("@ID", itemId);
    cmd.ExecuteNonQuery();
        }

            ShowMessage("Menu item deleted successfully!", true);
LoadMenuItems("All");
      }
            }
         catch (Exception ex)
    {
     ShowMessage("Error deleting item: " + ex.Message, false);
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
