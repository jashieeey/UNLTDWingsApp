using System;
using System.Web.UI;

namespace UNLTDWingsApp
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Role-aware landing page
            if (Session["UserID"] != null)
            {
                string role = (Session["Role"] ?? string.Empty).ToString();
                if (role.Equals("Staff", StringComparison.OrdinalIgnoreCase) || role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("Dashboard.aspx");
                    return;
                }

                // Logged in but not staff/admin (e.g., table account)
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            // Guest checkout session (no user)
            if (Session["IsGuest"] != null && Session["IsGuest"] is bool && (bool)Session["IsGuest"])
            {
                Response.Redirect("GuestMenu.aspx");
                return;
            }

            Response.Redirect("Login.aspx");
        }
    }
}