<%@ Page Title="Welcome" Language="C#" AutoEventWireup="true" CodeBehind="GuestWelcome.aspx.cs" Inherits="UNLTDWingsApp.GuestWelcome" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Welcome - UNLTD Wings</title>
 <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        /* Specific page override for full viewport bg */
        body {
            /* Fallback or specific override if needed beyond .unltd-login-bg */
            display: flex;
            align-items: center;
            justify-content: center;
        }
    </style>
</head>
<body class="unltd-login-bg">
    <form id="form1" runat="server">
      <div class="container" style="max-width: 420px;">
        <!-- Brand Section -->
        <div class="text-center mb-4">
             <div class="unltd-logo-circle mb-3">
                <div class="text-center lh-1" style="color: #FFD700; font-weight: bold; font-size: 14px;">
                    <span class="d-block fs-4"><i class="bi bi-fire"></i></span>
                    UNLTD<br/>WINGS
                </div>
            </div>
            <div class="text-white-50 small">Unlimited Wings Restaurant</div>
        </div>

        <div class="unltd-glass-panel position-relative">
            <!-- Back Button -->
            <a href="Login.aspx" class="btn btn-outline-warning rounded-circle d-flex align-items-center justify-content-center position-absolute top-0 start-0 m-3 border-0 shadow-sm" style="width:40px;height:40px; background:rgba(255,255,255,0.1);">
                <i class="bi bi-arrow-left"></i>
            </a>

            <!-- Avatar -->
            <div class="unltd-avatar-circle mx-auto mb-4 shadow-lg">
                <i class="bi bi-person-fill display-3 text-secondary"></i>
            </div>

            <!-- Welcome Text -->
            <h1 class="h4 fw-bold text-dark text-center mb-2">Welcome Guest!</h1>
            <p class="text-secondary text-center mb-4 small">How would you like to proceed?</p>

            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block text-center py-2 mb-3 small" Visible="false"></asp:Label>

            <div class="d-grid gap-3">
                <asp:LinkButton ID="btnTakeout" runat="server" CssClass="btn btn-warning text-white fw-bold rounded-pill w-100 py-3 d-flex align-items-center justify-content-center border-0 shadow-sm" style="background: linear-gradient(135deg, #FF8C00 0%, #FF6B00 100%);" OnClick="btnOrderType_Click" CommandArgument="Takeout">
                    <i class="bi bi-bag-check me-2 fs-5"></i>Ordering for Take-out
                </asp:LinkButton>
                
                <asp:LinkButton ID="btnDelivery" runat="server" CssClass="btn btn-success fw-bold text-white rounded-pill w-100 py-3 d-flex align-items-center justify-content-center border-0 shadow-sm" style="background: linear-gradient(135deg, #28a745 0%, #218838 100%);" OnClick="btnOrderType_Click" CommandArgument="Delivery">
                    <i class="bi bi-truck me-2 fs-5"></i>Ordering for Delivery
                </asp:LinkButton>
            </div>

            <div class="border-top border-secondary mt-4 pt-3 text-center text-secondary small opacity-75">
                <i class="bi bi-info-circle text-warning me-1"></i>
                Dine-in? Use the table account provided.
            </div>
        </div>
    </div>
    </form>
    
    <script src="Scripts/app.js"></script>
</body>
</html>
