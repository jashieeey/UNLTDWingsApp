using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class InventoryManagement : System.Web.UI.Page
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
     LoadInventory();
        LoadStats();
    }
        }

        protected void btnBack_Click(object sender, EventArgs e)
    {
    Response.Redirect("Dashboard.aspx");
        }

        protected void btnShowAdd_Click(object sender, EventArgs e)
{
       ClearForm();
      lblFormTitle.Text = "Add New Inventory Item";
 pnlForm.Visible = true;
      pnlRestock.Visible = false;
        }

  protected void btnCancelForm_Click(object sender, EventArgs e)
        {
pnlForm.Visible = false;
            ClearForm();
  }

        protected void btnCancelRestock_Click(object sender, EventArgs e)
        {
    pnlRestock.Visible = false;
        }

  private void ClearForm()
{
         hfItemID.Value = "0";
txtIngredientName.Text = "";
 txtStockLevel.Text = "";
   ddlUnit.SelectedIndex = 0;
       txtReorderLevel.Text = "";
   }

  private void LoadStats()
     {
      try
     {
    using (SqlConnection conn = new SqlConnection(connString))
        {
         conn.Open();

     // Total items
     using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Inventory", conn))
      {
    lblTotalItems.Text = cmd.ExecuteScalar().ToString();
  }

  // Low stock (at or below reorder level but > 0)
   using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Inventory WHERE StockLevel <= ReorderLevel AND StockLevel > 0", conn))
     {
lblLowStock.Text = cmd.ExecuteScalar().ToString();
      }

         // Out of stock
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Inventory WHERE StockLevel <= 0", conn))
   {
     lblOutOfStock.Text = cmd.ExecuteScalar().ToString();
        }
  }
      }
       catch { }
        }

      private void LoadInventory()
  {
   try
       {
      using (SqlConnection conn = new SqlConnection(connString))
        {
  string query = "SELECT InventoryID, IngredientName, StockLevel, Unit, ReorderLevel FROM Inventory ORDER BY IngredientName";
   SqlDataAdapter da = new SqlDataAdapter(query, conn);
        DataTable dt = new DataTable();
da.Fill(dt);

  if (dt.Rows.Count > 0)
        {
       rptInventory.DataSource = dt;
       rptInventory.DataBind();
       pnlNoItems.Visible = false;
   }
          else
      {
 rptInventory.DataSource = null;
         rptInventory.DataBind();
             pnlNoItems.Visible = true;
       }
     }
  }
          catch (Exception ex)
            {
              ShowMessage("Error loading inventory: " + ex.Message, false);
            }
        }

protected void btnSave_Click(object sender, EventArgs e)
     {
       if (string.IsNullOrWhiteSpace(txtIngredientName.Text) || 
         string.IsNullOrWhiteSpace(txtStockLevel.Text) ||
      string.IsNullOrWhiteSpace(txtReorderLevel.Text))
       {
        ShowMessage("Please fill in all required fields.", false);
   return;
     }

   decimal stockLevel, reorderLevel;
    if (!decimal.TryParse(txtStockLevel.Text, out stockLevel) || stockLevel < 0)
            {
      ShowMessage("Please enter a valid stock level.", false);
  return;
 }
     if (!decimal.TryParse(txtReorderLevel.Text, out reorderLevel) || reorderLevel < 0)
   {
         ShowMessage("Please enter a valid reorder level.", false);
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
   string query = @"INSERT INTO Inventory (IngredientName, StockLevel, Unit, ReorderLevel) 
     VALUES (@Name, @Stock, @Unit, @Reorder)";
    using (SqlCommand cmd = new SqlCommand(query, conn))
      {
         cmd.Parameters.AddWithValue("@Name", txtIngredientName.Text.Trim());
       cmd.Parameters.AddWithValue("@Stock", stockLevel);
  cmd.Parameters.AddWithValue("@Unit", ddlUnit.SelectedValue);
     cmd.Parameters.AddWithValue("@Reorder", reorderLevel);
    cmd.ExecuteNonQuery();
        }
              ShowMessage("Inventory item added successfully!", true);
 }
         else
     {
      string query = @"UPDATE Inventory SET IngredientName = @Name, StockLevel = @Stock, 
   Unit = @Unit, ReorderLevel = @Reorder, LastUpdated = GETDATE() 
   WHERE InventoryID = @ID";
        using (SqlCommand cmd = new SqlCommand(query, conn))
 {
  cmd.Parameters.AddWithValue("@ID", itemId);
cmd.Parameters.AddWithValue("@Name", txtIngredientName.Text.Trim());
     cmd.Parameters.AddWithValue("@Stock", stockLevel);
     cmd.Parameters.AddWithValue("@Unit", ddlUnit.SelectedValue);
     cmd.Parameters.AddWithValue("@Reorder", reorderLevel);
   cmd.ExecuteNonQuery();
 }
        ShowMessage("Inventory item updated successfully!", true);
   }

              pnlForm.Visible = false;
         ClearForm();
    LoadInventory();
    LoadStats();
 }
  }
      catch (Exception ex)
            {
    ShowMessage("Error saving inventory item: " + ex.Message, false);
            }
        }

        protected void rptInventory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
     if (e.CommandName == "Edit")
{
       int itemId = int.Parse(e.CommandArgument.ToString());
 LoadItemForEdit(itemId);
 }
       else if (e.CommandName == "Restock")
   {
     string[] args = e.CommandArgument.ToString().Split('|');
           hfRestockID.Value = args[0];
  lblRestockItem.Text = args[1];
   txtRestockQty.Text = "";
  pnlRestock.Visible = true;
          pnlForm.Visible = false;
  }
        }

        private void LoadItemForEdit(int itemId)
 {
     try
  {
          using (SqlConnection conn = new SqlConnection(connString))
    {
  string query = "SELECT * FROM Inventory WHERE InventoryID = @ID";
     using (SqlCommand cmd = new SqlCommand(query, conn))
     {
      cmd.Parameters.AddWithValue("@ID", itemId);
 conn.Open();
    using (SqlDataReader reader = cmd.ExecuteReader())
        {
             if (reader.Read())
   {
  hfItemID.Value = itemId.ToString();
                  txtIngredientName.Text = reader["IngredientName"].ToString();
         txtStockLevel.Text = Convert.ToDecimal(reader["StockLevel"]).ToString("0.##");
      ddlUnit.SelectedValue = reader["Unit"].ToString();
       txtReorderLevel.Text = Convert.ToDecimal(reader["ReorderLevel"]).ToString("0.##");

            lblFormTitle.Text = "Edit Inventory Item";
       pnlForm.Visible = true;
     pnlRestock.Visible = false;
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

        protected void btnConfirmRestock_Click(object sender, EventArgs e)
        {
      decimal qty;
  if (!decimal.TryParse(txtRestockQty.Text, out qty) || qty <= 0)
            {
           ShowMessage("Please enter a valid quantity to add.", false);
    return;
 }

     try
            {
        int inventoryId = int.Parse(hfRestockID.Value);
              using (SqlConnection conn = new SqlConnection(connString))
   {
 string query = "UPDATE Inventory SET StockLevel = StockLevel + @Qty, LastUpdated = GETDATE() WHERE InventoryID = @ID";
     using (SqlCommand cmd = new SqlCommand(query, conn))
      {
       cmd.Parameters.AddWithValue("@ID", inventoryId);
    cmd.Parameters.AddWithValue("@Qty", qty);
conn.Open();
       cmd.ExecuteNonQuery();
    }
        }

       ShowMessage($"Successfully added {qty} to {lblRestockItem.Text}!", true);
      pnlRestock.Visible = false;
 LoadInventory();
      LoadStats();
 }
        catch (Exception ex)
   {
      ShowMessage("Error restocking: " + ex.Message, false);
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
