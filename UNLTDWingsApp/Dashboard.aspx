<%@ Page Title="Dashboard" Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="UNLTDWingsApp.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script>
        // Auto-refresh pending count every 30 seconds
        setInterval(function() {
            var badge = document.getElementById('<%= pnlPendingAlert.ClientID %>');
        if(badge && badge.style.display !== 'none') {
         badge.classList.add('animate-pulse');
            }
        }, 5000);

        // Notification sound for pending orders - repeated beep pattern for staff attention
        var _pendingSoundPlayed = false;
    function playPendingNotification() {
   if (_pendingSoundPlayed) return;
            _pendingSoundPlayed = true;
      try {
          var ctx = new (window.AudioContext || window.webkitAudioContext)();
function beep(time) {
           var osc = ctx.createOscillator();
            var gain = ctx.createGain();
       osc.connect(gain);
              gain.connect(ctx.destination);
        osc.frequency.value = 880;
       osc.type = 'sine';
  gain.gain.value = 0.25;
 osc.start(ctx.currentTime + time);
               gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + time + 0.25);
          osc.stop(ctx.currentTime + time + 0.25);
  }
        // Play 3 quick beeps for attention
       beep(0);
    beep(0.35);
         beep(0.7);
    } catch(e) { /* silently fail if AudioContext not available */ }
        }

        document.addEventListener('DOMContentLoaded', function() {
      var pendingLabel = document.getElementById('<%= lblPendingCount.ClientID %>');
     if (pendingLabel && parseInt(pendingLabel.innerText) > 0) {
      playPendingNotification();
       // Also play on first click if autoplay blocked
     document.addEventListener('click', function onFirst() {
    playPendingNotification();
           document.removeEventListener('click', onFirst);
}, { once: true });
   }
        });
    </script>
</head>
<body class="unltd-admin">
    <form id="form1" runat="server">
        <div class="unltd-container pt-sm-3">
            <!-- Header Section -->
            <div class="admin-header d-flex justify-content-between align-items-center mb-4 pb-3 border-bottom border-light border-opacity-25 animate-fade-in-down">
                <div class="d-flex align-items-center">
                    <div class="rounded-circle bg-white text-dark d-flex align-items-center justify-content-center me-3 shadow-sm" style="width: 45px; height: 45px;">
                         <i class="bi bi-person-fill fs-4"></i>
                    </div>
                    <div>
                        <div class="h5 mb-0 fw-bold text-white">Welcome back, <asp:Label ID="lblUserName" runat="server" CssClass="text-warning"></asp:Label></div>
                        <small class="text-white-50">Role: <asp:Label ID="lblRole" runat="server"></asp:Label></small>
                    </div>
                </div>
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="btn btn-outline-light rounded-pill px-4" OnClick="btnLogout_Click">
                    <i class="bi bi-box-arrow-right me-2"></i> Logout
                </asp:LinkButton>
            </div>

            <!-- Pending Alert Banner (RED) -->
            <asp:LinkButton ID="btnPendingAlert" runat="server" OnClick="btnPendingAlert_Click" CssClass="text-decoration-none w-100 d-block mb-4 animate-fade-in-up stagger-1">
                <asp:Panel ID="pnlPendingAlert" runat="server" CssClass="admin-alert-pending" Visible="false">
                    <div class="d-flex align-items-center gap-3">
                         <!-- Light Icon Box for Dark BG -->
                         <div class="admin-icon-box light large" style="width:50px;height:50px;background:rgba(255,255,255,0.2);">
                            <i class="bi bi-bell-fill fs-4"></i>
                         </div>
                         <div class="d-flex flex-column text-start">
                             <span class="fs-5 fw-bold">Pending Orders</span>
                             <span class="small opacity-75">Orders awaiting review: <asp:Label ID="lblPendingCount" runat="server" Text="0"></asp:Label></span>
                         </div>
                    </div>
                    <i class="bi bi-chevron-right ms-auto fs-4"></i>
                </asp:Panel>
            </asp:LinkButton>

            <!-- Stats Grid -->
            <div class="row g-3 mb-5 animate-fade-in-up stagger-2">
                <div class="col-md-4">
                    <div class="admin-card card-hover">
                        <!-- Boxed Icon -->
                        <div class="admin-icon-box large">
                             <i class="bi bi-cash-coin"></i>
                        </div>
                        <div>
                            <div class="admin-stat-value">PHP <asp:Label ID="lblTodaySales" runat="server" Text="0.00"></asp:Label></div>
                            <div class="admin-stat-label">Total Sales Today</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="admin-card card-hover">
                        <!-- Boxed Icon -->
                        <div class="admin-icon-box large">
                             <i class="bi bi-receipt"></i>
                        </div>
                        <div>
                            <div class="admin-stat-value"><asp:Label ID="lblTodayOrders" runat="server" Text="0"></asp:Label></div>
                             <div class="admin-stat-label">Orders Completed Today</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="admin-card card-hover">
                        <!-- Boxed Icon -->
                        <div class="admin-icon-box large">
                             <i class="bi bi-arrow-repeat"></i>
                        </div>
                        <div>
                            <div class="admin-stat-value"><asp:Label ID="lblTodayRefills" runat="server" Text="0"></asp:Label></div>
                            <div class="admin-stat-label">Refills Processed Today</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="mb-5 animate-fade-in-up stagger-3">
    <h5 class="admin-section-title">Quick Actions</h5>
       
       <div class="row g-3">
              <div class="col-6 col-md-3">
          <asp:LinkButton ID="btnWalkIn" runat="server" CssClass="admin-action-btn w-100 h-100" OnClick="btnWalkIn_Click">
          <div class="admin-icon-box medium">
            <i class="bi bi-table"></i>
             </div>
            <span>Dine-in</span>
     </asp:LinkButton>
         </div>
              <div class="col-6 col-md-3">
    <asp:LinkButton ID="btnTakeOut" runat="server" CssClass="admin-action-btn w-100 h-100" OnClick="btnTakeOut_Click">
            <div class="admin-icon-box medium">
           <i class="bi bi-bag-check"></i>
 </div>
            <span>Take-out</span>
          </asp:LinkButton>
  </div>
   <div class="col-6 col-md-3">
      <asp:LinkButton ID="btnRefill" runat="server" CssClass="admin-action-btn w-100 h-100" OnClick="btnRefill_Click">
      <div class="admin-icon-box medium">
 <i class="bi bi-arrow-repeat"></i>
  </div>
 <span>Refill</span>
     </asp:LinkButton>
           </div>
       <div class="col-6 col-md-3">
  <asp:LinkButton ID="btnDelivery" runat="server" CssClass="admin-action-btn w-100 h-100" OnClick="btnDelivery_Click">
  <div class="admin-icon-box medium">
      <i class="bi bi-truck"></i>
                </div>
       <span>Delivery</span>
 </asp:LinkButton>
     </div>
     </div>
       <!-- Approvals & Today's Orders -->
    <div class="row g-3 mt-1 animate-fade-in-up stagger-4">
        <div class="col-6 col-md-3">
          <asp:LinkButton ID="btnPendingOrders" runat="server" CssClass="admin-action-btn btn-danger-soft w-100 h-100" OnClick="btnPendingOrders_Click">
         <div class="admin-icon-box medium">
<i class="bi bi-clipboard-check"></i>
              </div>
   <span>Approvals</span>
           </asp:LinkButton>
 </div>
             <div class="col-6 col-md-3">
            <asp:LinkButton ID="btnTodaysOrders" runat="server" CssClass="admin-action-btn w-100 h-100" OnClick="btnTodaysOrders_Click">
   <div class="admin-icon-box medium">
    <i class="bi bi-list-check"></i>
              </div>
             <span>Today's Orders</span>
    </asp:LinkButton>
 </div>
      </div>
            </div>

            <!-- Admin Actions -->
            <asp:Panel ID="pnlAdminActions" runat="server" CssClass="mb-4 animate-fade-in-up stagger-5" Visible="false">
                <h5 class="admin-section-title">Administration</h5>
                <div class="admin-btn-grid" style="grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));">
                    <asp:LinkButton ID="btnMenu" runat="server" CssClass="admin-action-btn py-3" OnClick="btnMenu_Click">
                        <div class="admin-icon-box medium">
                            <i class="bi bi-journal-text"></i>
                        </div>
                        <span class="small">Menu Mgmt</span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnInventory" runat="server" CssClass="admin-action-btn py-3" OnClick="btnInventory_Click">
                         <div class="admin-icon-box medium">
                            <i class="bi bi-box-seam"></i>
                        </div>
                        <span class="small">Inventory</span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnReports" runat="server" CssClass="admin-action-btn py-3" OnClick="btnReports_Click">
                         <div class="admin-icon-box medium">
                            <i class="bi bi-bar-chart-line"></i>
                        </div>
                        <span class="small">Reports</span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnAccounts" runat="server" CssClass="admin-action-btn py-3" OnClick="btnAccounts_Click">
                         <div class="admin-icon-box medium">
                            <i class="bi bi-people"></i>
                        </div>
                        <span class="small">Accounts</span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnQRCodes" runat="server" CssClass="admin-action-btn py-3" OnClick="btnQRCodes_Click">
                         <div class="admin-icon-box medium">
                            <i class="bi bi-qr-code"></i>
                        </div>
                        <span class="small">QR Codes</span>
                    </asp:LinkButton>
                </div>
            </asp:Panel>

            <!-- Low Stock Alert Panel -->
            <asp:Panel ID="pnlLowStock" runat="server" Visible="false" CssClass="mt-4 p-3 bg-white rounded-3 shadow-sm border border-danger border-opacity-25 animate-fade-in-up">
                <div class="d-flex align-items-center mb-3 text-danger">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                    <h6 class="mb-0 fw-bold">Low Stock Alerts</h6>
                </div>
                <asp:Repeater ID="rptLowStock" runat="server">
                    <ItemTemplate>
                        <div class="d-flex justify-content-between border-bottom border-light py-2">
                            <span class="text-dark"><%# Eval("IngredientName") %></span>
                            <span class="text-danger fw-bold"><%# Eval("StockLevel") %> <%# Eval("Unit") %></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
        </div>
        
        <!-- Footer Nav Placeholder (For mobile feel) -->
        <div class="admin-footer-nav d-md-none">
             <a href="Dashboard.aspx" class="admin-footer-item active">
                 <i class="bi bi-house-door-fill"></i>
                 Home
             </a>
             <a href="TodaysOrders.aspx" class="admin-footer-item">
                 <i class="bi bi-receipt"></i>
                 Orders
             </a>
             <a href="InventoryManagement.aspx" class="admin-footer-item">
                 <i class="bi bi-box-seam"></i>
                 Stock
             </a>
             <a href="Reports.aspx" class="admin-footer-item">
                 <i class="bi bi-bar-chart"></i>
                 Stats
             </a>
        </div>
        <div class="d-md-none" style="height: 60px;"></div> <!-- Spacer for footer -->
        
    </form>
</body>
</html>