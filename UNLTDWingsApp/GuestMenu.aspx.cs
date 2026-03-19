using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace UNLTDWingsApp
{
    public partial class GuestMenu : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Allow access if guest chose order type, even if name isn't collected yet.
            bool isGuest = Session["IsGuest"] != null && Session["IsGuest"] is bool && (bool)Session["IsGuest"]; 
            bool isTable = Session["IsTableAccount"] != null && Session["IsTableAccount"] is bool && (bool)Session["IsTableAccount"]; 

            if (!isGuest && !isTable)
            {
                Response.Redirect("GuestWelcome.aspx");
                return;
            }

            // Normalize order type rules
            if (isTable)
            {
                Session["GuestOrderType"] = "Dine-in";
                Session["IsGuest"] = false; // table accounts aren't "guest checkout"
            }
            else
            {
                // Guests must have an allowed order type
                string ot = (Session["GuestOrderType"] ?? string.Empty).ToString();
                if (ot != "Takeout" && ot != "Delivery")
                {
                    Session["GuestOrderType"] = "Takeout";
                }
            }

            if (!IsPostBack)
            {
                string guestName = (Session["GuestName"] ?? (isTable ? (Session["GuestName"] ?? "Table") : "Guest")).ToString();
                lblGuestName.Text = string.IsNullOrWhiteSpace(guestName) ? "Guest" : guestName;

                // Set account type label
                if (isTable)
                {
                    lblAccountType.Text = "Table " + (Session["TableNumber"] ?? "");
                }
                else
                {
                    lblAccountType.Text = "Guest";
                }

                InitializeCart();
                LoadMenuItems("All");
                LoadTopFavourites();
                UpdateCartCount();
                
                // Set initial active category button
                SetActiveCategoryButton("All");
            }
        }

        private void InitializeCart()
        {
            if (Session["GuestCart"] == null)
            {
                DataTable dtCart = new DataTable();
                dtCart.Columns.Add("ItemID", typeof(int));
                dtCart.Columns.Add("ItemName", typeof(string));
                dtCart.Columns.Add("Price", typeof(decimal));
                dtCart.Columns.Add("Quantity", typeof(int));
                dtCart.Columns.Add("Subtotal", typeof(decimal));
                Session["GuestCart"] = dtCart;
            }
        }

        private void LoadMenuItems(string category)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // Include ImageUrl in the query to get item-specific images
                    string query = "SELECT ItemID, ItemName, ItemDescription, ItemCategory, Price, ImageUrl FROM Menu_Item WHERE IsAvailable = 1";

                    if (category != "All")
                    {
                        query += " AND ItemCategory = @Category";
                    }

                    query += " ORDER BY CASE WHEN ItemCategory IN ('Unlimited','Wings') THEN 0 WHEN ItemCategory = 'Rice Meals' THEN 1 WHEN ItemCategory='Combos' THEN 2 WHEN ItemCategory='Fries' THEN 3 WHEN ItemCategory='Pasta' THEN 4 ELSE 5 END, ItemName";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (category != "All")
                        {
                            cmd.Parameters.AddWithValue("@Category", category);
                        }

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptMenuItems.DataSource = dt;
                            rptMenuItems.DataBind();
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            rptMenuItems.DataSource = null;
                            rptMenuItems.DataBind();
                            pnlEmpty.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Show error in empty state with helpful message
                pnlEmpty.Visible = true;
                System.Diagnostics.Debug.WriteLine("Menu Load Error: " + ex.Message);
            }
        }

        protected void btnCategory_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string category = btn.CommandArgument;

            SetActiveCategoryButton(category);
            LoadMenuItems(category);
        }

        private void SetActiveCategoryButton(string category)
        {
            // Reset all category button styles
            btnAll.CssClass = "category-btn";
            btnUnlimited.CssClass = "category-btn";
            btnWings.CssClass = "category-btn";
            btnRiceMeals.CssClass = "category-btn";
            btnPasta.CssClass = "category-btn";
            btnCombos.CssClass = "category-btn";
            btnFries.CssClass = "category-btn";
            btnDrinks.CssClass = "category-btn";
            btnAddons.CssClass = "category-btn";

            // Set active button based on category
            switch (category)
            {
                case "All": btnAll.CssClass = "category-btn active"; break;
                case "Unlimited": btnUnlimited.CssClass = "category-btn active"; break;
                case "Wings": btnWings.CssClass = "category-btn active"; break;
                case "Rice Meals": btnRiceMeals.CssClass = "category-btn active"; break;
                case "Pasta": btnPasta.CssClass = "category-btn active"; break;
                case "Combos": btnCombos.CssClass = "category-btn active"; break;
                case "Fries": btnFries.CssClass = "category-btn active"; break;
                case "Drinks": btnDrinks.CssClass = "category-btn active"; break;
                case "Add-ons": btnAddons.CssClass = "category-btn active"; break;
                default: btnAll.CssClass = "category-btn active"; break;
            }
        }

        protected void rptMenuItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "AddToCart")
            {
                // Rate limit add-to-cart to prevent spam
                if (!UNLTDWingsApp.Utilities.RateLimiter.CanAddToCart(Session.SessionID))
                {
                    hfShowToast.Value = "0";
                    return;
                }

                string[] args = e.CommandArgument.ToString().Split(',');
                int itemId = int.Parse(args[0]);
                string itemName = args[1];
                decimal price = decimal.Parse(args[2]);

                AddToCart(itemId, itemName, price);
                hfShowToast.Value = "1";
            }
        }

        private void AddToCart(int itemId, string itemName, decimal price)
        {
            DataTable dtCart = (DataTable)Session["GuestCart"];

            // Check if item already exists in cart
            DataRow[] existingRows = dtCart.Select($"ItemID = {itemId}");

            if (existingRows.Length > 0)
            {
                // Increment quantity
                int currentQty = Convert.ToInt32(existingRows[0]["Quantity"]);
                existingRows[0]["Quantity"] = currentQty + 1;
                existingRows[0]["Subtotal"] = price * (currentQty + 1);
            }
            else
            {
                // Add new item
                DataRow newRow = dtCart.NewRow();
                newRow["ItemID"] = itemId;
                newRow["ItemName"] = itemName;
                newRow["Price"] = price;
                newRow["Quantity"] = 1;
                newRow["Subtotal"] = price;
                dtCart.Rows.Add(newRow);
            }

            Session["GuestCart"] = dtCart;
            UpdateCartCount();
        }

        private void UpdateCartCount()
        {
            DataTable dtCart = (DataTable)Session["GuestCart"];
            int totalItems = 0;

            foreach (DataRow row in dtCart.Rows)
            {
                totalItems += Convert.ToInt32(row["Quantity"]);
            }

            lblCartCount.Text = totalItems.ToString();
            lblCartCount.Visible = totalItems > 0;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        // Helper method to get the correct icon class for each category (fallback)
        protected string GetCategoryIcon(string category)
        {
            switch (category)
            {
                case "Unlimited":
                    return "bi bi-infinity";
                case "Wings":
                    return "bi bi-fire";
                case "Rice Meals":
                    return "bi bi-egg-fried";
                case "Pasta":
                    return "bi bi-cup-hot";
                case "Combos":
                    return "bi bi-box2-fill";
                case "Fries":
                    return "bi bi-basket-fill";
                case "Drinks":
                    return "bi bi-cup-straw";
                case "Add-ons":
                    return "bi bi-plus-circle-fill";
                default:
                    return "bi bi-circle-fill";
            }
        }

        // Helper method to get the correct image container class for each category
        protected string GetItemImageClass(string category)
        {
            string baseClass = "item-image ";
            switch (category)
            {
                case "Unlimited":
                    return baseClass + "unlimited";
                case "Wings":
                    return baseClass + "wings";
                case "Rice Meals":
                    return baseClass + "rice-meals";
                case "Pasta":
                    return baseClass + "pasta";
                case "Combos":
                    return baseClass + "combos";
                case "Fries":
                    return baseClass + "fries";
                case "Drinks":
                    return baseClass + "drinks";
                case "Add-ons":
                    return baseClass + "add-ons";
                default:
                    return baseClass + "wings";
            }
        }

        // Helper method to get actual image URL - uses database URL first, fallback to category default
        protected string GetImageUrl(object imageUrlObj, string category)
        {
            // First try to use the actual ImageUrl from database
            if (imageUrlObj != null && imageUrlObj != DBNull.Value && !string.IsNullOrEmpty(imageUrlObj.ToString()))
            {
                return imageUrlObj.ToString();
            }

            // Fallback to category-based default images
            switch (category)
            {
                case "Unlimited":
                    return "https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=200&h=200&fit=crop&q=80";
                case "Wings":
                    return "https://images.unsplash.com/photo-1608039755401-742074f0548d?w=200&h=200&fit=crop&q=80";
                case "Rice Meals":
                    return "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=200&h=200&fit=crop&q=80";
                case "Pasta":
                    return "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=200&h=200&fit=crop&q=80";
                case "Combos":
                    return "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop&q=80";
                case "Fries":
                    return "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=200&h=200&fit=crop&q=80";
                case "Drinks":
                    return "https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200&h=200&fit=crop&q=80";
                case "Add-ons":
                    return "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop&q=80";
                default:
                    return "https://images.unsplash.com/photo-1608039755401-742074f0548d?w=200&h=200&fit=crop&q=80";
            }
        }

        // Helper method to highlight favorite items based on category
        protected string GetItemClass(string category)
        {
            string baseClass = "menu-item";
            if (category == "Unlimited" || category == "Combos")
            {
                baseClass += " favorite";
            }
            return baseClass;
        }

        /// <summary>
        /// Load top favourite / highlight menu items based on order frequency or curated picks
        /// </summary>
        private void LoadTopFavourites()
        {
          try
     {
     using (SqlConnection conn = new SqlConnection(connString))
        {
    // Get top 6 best sellers from order history, fallback to curated picks
    string query = @"
SELECT TOP 6 m.ItemID, m.ItemName, m.ItemCategory, m.Price, m.ImageUrl
FROM Menu_Item m
LEFT JOIN (
    SELECT oi.ItemID, SUM(oi.Quantity) AS TotalOrdered
    FROM Order_Item oi
 INNER JOIN Orders o ON oi.OrderID = o.OrderID
    WHERE o.OrderDate >= DATEADD(DAY, -30, GETDATE())
    GROUP BY oi.ItemID
) sales ON m.ItemID = sales.ItemID
WHERE m.IsAvailable = 1
ORDER BY ISNULL(sales.TotalOrdered, 0) DESC, 
         CASE WHEN m.ItemCategory IN ('Unlimited','Combos','Wings') THEN 0 ELSE 1 END,
         m.Price DESC";

   using (SqlCommand cmd = new SqlCommand(query, conn))
 {
          SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
    da.Fill(dt);

             if (dt.Rows.Count > 0)
     {
   rptTopFavourites.DataSource = dt;
     rptTopFavourites.DataBind();
              }
          }
         }
            }
            catch (Exception ex)
      {
      System.Diagnostics.Debug.WriteLine("Error loading top favourites: " + ex.Message);
}
        }
    }
}
