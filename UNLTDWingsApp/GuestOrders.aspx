<%@ Page Title="My Orders" Language="C#" AutoEventWireup="true" CodeBehind="GuestOrders.aspx.cs" Inherits="UNLTDWingsApp.GuestOrders" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Orders - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: #1a1a1a; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; min-height:100vh; }
  .orders-header { background: linear-gradient(135deg, #2C1810 0%, #5E2D10 100%); padding:15px 20px; position:sticky; top:0; z-index:100; }
        .order-card { background: #2C2C2C; border-radius:16px; padding:16px; margin-bottom:12px; border:1px solid #3a3a3a; transition: all 0.3s; }
        .order-card:hover { border-color: #FF8C00; }
        .status-badge { padding:5px 14px; border-radius:20px; font-size:12px; font-weight:700; display:inline-flex; align-items:center; gap:4px; }
        .status-pending { background: rgba(255,193,7,0.15); color:#ffc107; border:1px solid rgba(255,193,7,0.3); }
        .status-approved { background: rgba(40,167,69,0.15); color:#28a745; border:1px solid rgba(40,167,69,0.3); }
        .status-completed { background: rgba(40,167,69,0.25); color:#2ecc71; border:1px solid rgba(40,167,69,0.4); }
  .status-cancelled { background: rgba(220,53,69,0.15); color:#dc3545; border:1px solid rgba(220,53,69,0.3); }
     .type-badge { padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600; }
        .type-dine-in { background:#E7F3FF; color:#007bff; }
   .type-takeout { background:#FFF8E1; color:#e6a100; }
        .type-delivery { background:#E8F5E9; color:#28a745; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="orders-header">
     <div class="d-flex justify-content-between align-items-center">
      <div class="d-flex align-items-center gap-2">
           <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="text-white text-decoration-none" style="font-size:1.3rem;">
   <i class="bi bi-arrow-left"></i>
                    </asp:LinkButton>
       <h5 class="m-0 text-white fw-bold">My Orders</h5>
       </div>
           <div class="text-warning fw-bold small"><i class="bi bi-fire me-1"></i>UNLTD WINGS</div>
       </div>
        </div>

   <div class="p-3" style="max-width:600px; margin:0 auto;">
<!-- Auto-refresh notice -->
            <div class="text-center text-white-50 small mb-3">
          <i class="bi bi-arrow-clockwise me-1"></i>Auto-refreshing every 10 seconds
    </div>

     <!-- Orders List -->
 <asp:Repeater ID="rptOrders" runat="server">
      <ItemTemplate>
          <div class="order-card">
         <div class="d-flex justify-content-between align-items-start mb-2">
             <div>
          <span class="text-warning fw-bold">Order #<%# Eval("OrderID") %></span>
       <span class='type-badge ms-2 <%# GetTypeCss(Eval("OrderType").ToString()) %>'><%# Eval("OrderType") %></span>
      </div>
        <span class='status-badge <%# GetStatusBadgeCss(Eval("OrderStatus").ToString()) %>'>
           <i class='<%# GetStatusIcon(Eval("OrderStatus").ToString()) %>'></i>
    <%# Eval("OrderStatus") %>
   </span>
   </div>

         <div class="d-flex justify-content-between small mb-2">
        <span class="text-white-50"><i class="bi bi-clock me-1"></i><%# Eval("OrderDate", "{0:MMM dd, hh:mm tt}") %></span>
  <span class="text-white-50"><i class="bi bi-credit-card me-1"></i><%# Eval("PaymentMethod") %></span>
    </div>

         <div class="d-flex justify-content-between align-items-center pt-2 border-top" style="border-color:#3a3a3a !important;">
        <span class="text-white fw-bold">Total: <span class="text-warning">PHP <%# Eval("TotalAmount", "{0:N2}") %></span></span>
      <%# Eval("OrderStatus").ToString() == "Pending" ? "<span class='text-warning small'><i class='bi bi-hourglass-split me-1'></i>Awaiting approval...</span>" :
     Eval("OrderStatus").ToString() == "Approved" ? "<span class='text-success small'><i class='bi bi-check-circle me-1'></i>Order approved!</span>" :
          Eval("OrderStatus").ToString() == "Cancelled" ? "<span class='text-danger small'><i class='bi bi-x-circle me-1'></i>Order rejected</span>" :
   "<span class='text-success small'><i class='bi bi-check-all me-1'></i>Completed</span>" %>
         </div>
       </div>
                </ItemTemplate>
  </asp:Repeater>

     <!-- Empty State -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="text-center py-5">
           <div class="mb-3 text-secondary opacity-50">
     <i class="bi bi-receipt display-1"></i>
 </div>
           <h5 class="text-warning fw-bold">No orders yet</h5>
 <p class="text-white-50 small mb-4">Start adding delicious wings to your cart!</p>
                <a href="GuestMenu.aspx" class="btn btn-warning rounded-pill px-4 fw-bold text-white">
      View Menu
         </a>
         </asp:Panel>
  </div>
    </form>

    <script src="Scripts/app.js"></script>
    <script>
        // Auto-refresh every 10 seconds
        setInterval(function() {
        if (typeof __doPostBack === 'function') {
       __doPostBack('', '');
    }
        }, 10000);
    </script>
</body>
</html>
