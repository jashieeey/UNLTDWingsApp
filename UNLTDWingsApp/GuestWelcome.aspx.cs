using System;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace UNLTDWingsApp
{
    public partial class GuestWelcome : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["UNLTDWingsDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // If guest already picked an order type, go straight to menu
            if (Session["IsGuest"] != null && (bool)Session["IsGuest"] == true && Session["GuestOrderType"] != null)
            {
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Ensure table session cleared for non-table guests
                Session.Remove("TableNumber");
                Session.Remove("IsTableAccount");
                Session.Remove("GuestOrderIDs"); 
            }
        }

        protected void btnOrderType_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string orderType = btn.CommandArgument; // Takeout or Delivery

            Session["IsGuest"] = true;
            Session["GuestOrderType"] = orderType;
            
            // Generate temporary account container for orders
            Session["GuestOrderIDs"] = new List<int>();

            // Guest name is collected at checkout (GuestCart)
            if (Session["GuestName"] != null && Session["GuestName"].ToString().StartsWith("Guest", StringComparison.OrdinalIgnoreCase))
            {
                Session.Remove("GuestName");
            }

            Response.Redirect("GuestMenu.aspx");
        }
    }
}
