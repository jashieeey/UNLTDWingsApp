    <%@ Page Title="Pending Orders - Approvals" Language="C#" AutoEventWireup="true" CodeBehind="PendingOrders.aspx.cs" Inherits="UNLTDWingsApp.PendingOrders" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Pending Orders - UNLTD Wings</title>
  <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
      
        body {
        background: linear-gradient(135deg, #dc3545 0%, #a71930 100%);
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height: 100vh;
        }
        
 /* DANGER/RED THEME */
   .header {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            padding: 20px;
 display: flex;
          align-items: center;
            gap: 15px;
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3);
 position: sticky;
         top: 0;
   z-index: 100;
 }
        
        .back-btn { color: white; font-size: 1.5rem; text-decoration: none; transition: all 0.3s; }
        .back-btn:hover { color: #fff; transform: scale(1.1); }
     
        .page-title { color: white; font-size: 20px; font-weight: 700; flex: 1; }
        
        .pending-count {
            background: white;
            color: #dc3545;
   padding: 8px 18px;
     border-radius: 25px;
        font-weight: 700;
      font-size: 18px;
            animation: pulse 2s ease-in-out infinite;
     box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        .content { padding: 20px; }
 
        .order-card {
        background: white;
            border-radius: 15px;
    padding: 20px;
  margin-bottom: 15px;
          box-shadow: 0 4px 15px rgba(0,0,0,0.1);
       border-left: 5px solid #dc3545;
            opacity: 1;
            animation: fadeInUp 0.4s ease forwards;
 position: relative;
        }
        
        .order-card.dine-in { border-left-color: #007bff; }
     .order-card.delivery { border-left-color: #28a745; }
        .order-card.takeout { border-left-color: #ffc107; }
        
        .order-card:nth-child(1) { animation-delay: 0.1s; }
 .order-card:nth-child(2) { animation-delay: 0.2s; }
        .order-card:nth-child(3) { animation-delay: 0.3s; }
        .order-card:nth-child(4) { animation-delay: 0.4s; }
        
.order-type-badge {
            position: absolute;
            top: 15px;
      right: 15px;
     padding: 6px 12px;
          border-radius: 20px;
      font-size: 11px;
  font-weight: 700;
            text-transform: uppercase;
        }

    .order-type-badge.dine-in { background: #E7F3FF; color: #007bff; }
        .order-type-badge.delivery { background: #E8F5E9; color: #28a745; }
.order-type-badge.takeout { background: #FFF8E1; color: #ffc107; }
        
.order-header {
       display: flex;
            justify-content: space-between;
          align-items: flex-start;
     margin-bottom: 15px;
      }
        
   .order-id { font-weight: 700; font-size: 18px; color: #dc3545; }
        .order-time { font-size: 13px; color: #888; margin-top: 5px; }
        
   .order-table {
        background: #E7F3FF;
            padding: 6px 14px;
  border-radius: 15px;
        font-size: 12px;
         font-weight: 600;
    color: #007bff;
        }
  
        .customer-section {
      margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #F0F0F0;
   }
        
        .info-row {
         display: flex;
   gap: 10px;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .info-label { color: #666; font-weight: 600; min-width: 80px; }
      .info-value { color: #333; }
        
        .gcash-ref {
    background: #F0F0F0;
          padding: 8px 12px;
         border-radius: 6px;
    font-family: monospace;
        font-size: 13px;
color: #28a745;
        font-weight: 600;
   }
        
  .order-items {
            margin-bottom: 15px;
      max-height: 200px;
        overflow-y: auto;
        }
        
     .order-item {
   display: flex;
            justify-content: space-between;
          padding: 8px 0;
      font-size: 14px;
            border-bottom: 1px solid #F8F8F8;
        }
        
        .item-name { color: #333; font-weight: 500; }
        .item-qty { color: #888; }
        
        .order-total {
    display: flex;
  justify-content: space-between;
          padding: 15px 0;
            border-top: 2px solid #dc3545;
            font-weight: 700;
     }
        
        .total-label { color: #666; font-size: 16px; }
        .total-value { color: #dc3545; font-size: 20px; }
        
        .action-buttons {
 display: flex;
         gap: 10px;
  margin-top: 15px;
        }
    
        .btn-approve, .btn-reject {
        flex: 1;
            color: white;
      border: none;
     border-radius: 10px;
     padding: 12px;
      font-weight: 600;
            transition: all 0.3s ease;
          cursor: pointer;
      font-size: 14px;
        }
        
      .btn-approve {
  background: #28a745;
     }
     
        .btn-approve:hover {
     background: #218838;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
        }
        
        .btn-reject {
            background: #dc3545;
        }
        
        .btn-reject:hover {
   background: #c82333;
     transform: translateY(-2px);
 box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
        }
        
        .empty-state {
 text-align: center;
          padding: 80px 20px;
  color: #666;
            animation: fadeInUp 0.5s ease forwards;
        }
        
        .empty-state i { font-size: 5rem; margin-bottom: 15px; color: white; opacity: 0.5; }
        .empty-state h3 { color: white; margin-bottom: 10px; }
    .empty-state p { color: rgba(255,255,255,0.8); margin-bottom: 20px; }
 
        .empty-state a {
         display: inline-block;
    margin-top: 20px;
 padding: 12px 30px;
       background: white;
 color: #dc3545;
     border-radius: 25px;
  text-decoration: none;
   font-weight: 600;
        transition: all 0.3s ease;
        }
        
   .empty-state a:hover {
            background: #f8f8f8;
            transform: translateY(-2px);
 }
        
     @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
       to { opacity: 1; transform: translateY(0); }
        }
      
        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 2px 8px rgba(0,0,0,0.2); }
            50% { transform: scale(1.05); box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
      }
        
        @keyframes shake {
 0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
        
 .notification-pulse {
   animation: shake 0.5s ease;
        }
        
.loading-overlay {
            display: none;
      position: fixed;
   top: 0;
            left: 0;
   right: 0;
 bottom: 0;
  background: rgba(0, 0, 0, 0.5);
            z-index: 999;
            align-items: center;
            justify-content: center;
        }
        
        .loading-overlay.active {
            display: flex;
        }
        
   .loading-spinner {
            width: 50px;
          height: 50px;
       border: 5px solid rgba(255, 255, 255, 0.3);
   border-radius: 50%;
        border-top: 5px solid white;
       animation: spin 1s linear infinite;
        }
        
 @keyframes spin {
  to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
  <!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
          <div style="text-align: center;">
          <div class="loading-spinner"></div>
   </div>
   </div>
        
        <!-- Audio for notification - proper alert tone -->
     <audio id="notificationSound" preload="auto">
   <source src="https://cdn.freesound.org/previews/536/536108_4921277-lq.mp3" type="audio/mpeg">
   <source src="data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdHuMkZWYl5KPi4eEf3t3dHFta2lmZGJgX11bWVdVU1FPTUtJR0VDQUQ+QkZKTlJWWl5iZmpucnZ6foKGio6SlpeamJaUkY6LiIV/fHl2c3BtamhmZGJgXltZV1VRUU9NTUpIRkRCQD48PDo4NjQyMDIwLi4uLC4sMC4yNDY4Ojw+QkRISkxQUlZYXF5iZGhqbnB0eHp+gISGioyOkJKUlpeZmZmXlZORj4yKiIR+fHh2cnBsaGZkYmBeXFpYVlRSUE5MSkhGRERCQEA+PDw6ODg2NjQ0NDQ2Njg4Ojw+QEJGSE5QVFhcYGRobG5ydnp8gIKEhoqMkJKUlpeamJiYlpSSkI6MiIaDf3x4dnJwbmpoZmRiYF5cWlhWVFJQTk5MSkhIRkZEREJCQEA+Pj48PDs8PD4+QEJESE5QVlhcYGRmaGxwcnR4enyAgoSIioyQkpSWl5iYmJiWlJKQjIqIhIKAfnh2cnBuampmZGJgXlxaWFZUUlBOTkxKSEhGRkRCQkJAQD4+PkBCQkRITE5QVFheYGRoam5wdHh6foKEiIqOkJSWl5iYmJaWlJKQjoyIhIKAfHh2cnBuamlmZGBgXlxaWFZWUlBOTkxKSkhGRkREQkJAQD4+QEJCREhMTlJUWFxeZGZqbG5ydnp8gIKGiIyOkpSWlpiYmJiWlJKOjIqIhIKAfHl2cnBuamhmZGJgXlxaWFZUUlBOTk5MSkhGRkREQkJAQD4+QEJCREVITE5SVFhcXmJkampucnR4fH6ChoiKjpKUlpeYmJaWlJKQjoyKiISCfnx4dHJwbGpoZmRiYF5cWlhWVFJQTk5MSkhIRkZEQkJAQEA+PkBCQkRITE5QVFhcXmJkampucnR4fICChoiMjpCSmpqamJiWlJKQjoyIhIKAfHp2dHBuampkZGJgXlxaWFZUUlJOTkxKSEhGRkREQkJAQD4+QEJGSE5QVFhaXmJkaGpucnR2enyAgoSIjI6SkpSYmJiYlpSSkI6MioiEgoB8eHRycG5saGZkYmBgXFpaWFZUUlBOTkxKSEhGREREQkJAQEBCREZITE5QVFhcXmJkaGxucnZ6fICChoiKjpKUlpiYmJiWlJKQjouIhIKAfnp2dHBuampoZmRiYF5cWlhWVFJQTk5MSkhIRkRCQkJAQD5AQkRGSExQUlRYXGBiZmpucnR4fICChoiMkJKUlpiYmJiWlJKQjoqIhIKAfHp2cnBuamhmZGJgYF5cWlhWVFJQTk5MSkhIRkZERERCQkBCREZITFBSVFhaXmBkZmpucnR4fH6ChoiMjpCUlpeYmJiWlpKQjoyKhoSCfnx4dnJwbmpoZmRiYF5cWlhWVFJSTk5MTEpISEZEREJCQEJCREhKTE5SVFhcYGJmaGxucnZ6fH6ChoqMjpKUlpeYmJiWlJKQjoyKhoSCfnx4dnJwbGpoZmRiYF5cWlhWVFJQUE5OTEpISEZGREJCQEJCRERITE5SVFhcXmJkaGxucnZ6fH6ChIiMjpCSl5aYmJiWlpKQjoyIhoSCfnx4dHJwbmpoZGRiYF5cWlhWVFJQTk5MTEpISEZEQkJCQEJERkhMTlBUWFpeYGRoam5wcnZ6fICCiIqOkJSWl5iYmJaUkpCOjIiGhIJ+fHh0cnBuamhmZGJgXlxaWFZUUlBOTkxMSkhGRkREQkBCQkRISkxOUlZYXGBiZmpucHR4fICChIiMjpKUlpiYmJiWlJKQjoqIhoSAfHp2dHBuampmZGJgXlxaWFZUUlBOTkxKSEhGRkRCQEJCREhKTlBUVlheYGRoam5wcnZ6fH6AhIiMjpKUlpeYmJiWlJKQjoyIhoJ+fHh2cnBuamhmZGJgXlxaWFZUUlBQTkxMSkhIRkZEQkJCQkRISkxQUlRYXF5iZGhsbnJ2eHp+goSIio6QlJaYmJiWlpSSjoyIhoSCfnx4dnJwbGpoZmRiYF5cWlg==" type="audio/wav">
   </audio>
        
        <!-- Header -->
        <div class="header">
            <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn" ToolTip="Back">
      <i class="bi bi-arrow-left"></i>
            </asp:LinkButton>
         <span class="page-title">
         <i class="bi bi-exclamation-circle me-2"></i>PENDING ORDERS
          </span>
   <span class="pending-count"><asp:Label ID="lblCount" runat="server" Text="0"></asp:Label></span>
     </div>

        <!-- Content -->
        <div class="content">
            <asp:Repeater ID="rptOrders" runat="server" OnItemCommand="rptOrders_ItemCommand" OnItemDataBound="rptOrders_ItemDataBound">
  <ItemTemplate>
     <div class="order-card" id="orderCard<%# Eval("OrderID") %>">
                <span class="order-type-badge <%# GetOrderTypeCss(Eval("OrderType").ToString()) %>">
 <%# Eval("OrderType") %>
 </span>
    
           <div class="order-header">
          <div>
        <div class="order-id">Order #<%# Eval("OrderID") %></div>
             <div class="order-time"><%# Eval("OrderDate", "{0:MMM dd, yyyy hh:mm tt}") %></div>
          </div>
       <%# Eval("TableNumber") != DBNull.Value && !string.IsNullOrEmpty(Eval("TableNumber").ToString()) ? "<span class='order-table'><i class='bi bi-table me-1'></i>Table " + Eval("TableNumber") + "</span>" : "" %>
            </div>
   
          <!-- Customer Section based on Order Type -->
  <div class="customer-section">
      <div class="info-row">
      <span class="info-label"><i class="bi bi-person"></i></span>
        <span class="info-value"><strong><%# Eval("CustomerName") %></strong></span>
         </div>
   
<!-- Delivery/Takeout Address -->
  <%# Eval("OrderType").ToString() != "Dine-in" && Eval("Address") != DBNull.Value && !string.IsNullOrEmpty(Convert.ToString(Eval("Address"))) ? 
          "<div class='info-row'><span class='info-label'><i class='bi bi-geo-alt'></i></span><span class='info-value'>" + Eval("Address") + "</span></div>" : "" %>
    
             <!-- Contact Number -->
  <%# Eval("ContactNumber") != DBNull.Value && !string.IsNullOrEmpty(Convert.ToString(Eval("ContactNumber"))) ? 
             "<div class='info-row'><span class='info-label'><i class='bi bi-telephone'></i></span><span class='info-value'>" + Eval("ContactNumber") + "</span></div>" : "" %>
 
 <!-- Payment Method & GCash Reference -->
  <%# Eval("PaymentMethod") != DBNull.Value && !string.IsNullOrEmpty(Convert.ToString(Eval("PaymentMethod"))) ? 
 "<div class='info-row'><span class='info-label'>Payment:</span><span class='info-value'>" + Eval("PaymentMethod") + "</span></div>" : "" %>
 
  <%# Convert.ToString(Eval("PaymentMethod")) == "GCash" && Eval("ReferenceNumber") != DBNull.Value && !string.IsNullOrEmpty(Convert.ToString(Eval("ReferenceNumber"))) ? 
         "<div class='info-row'><span class='info-label'>Ref #:</span><span class='gcash-ref'>" + Eval("ReferenceNumber") + "</span></div>" : "" %>
       </div>

     <!-- Order Items -->
     <div class="order-items">
        <asp:Repeater ID="rptItems" runat="server">
        <ItemTemplate>
         <div class="order-item">
       <span class="item-name"><%# Eval("ItemName") %></span>
       <span class="item-qty">x<%# Eval("Quantity") %> - PHP <%# Eval("Subtotal", "{0:N2}") %></span>
            </div>
     </ItemTemplate>
   </asp:Repeater>
      </div>

      <!-- Order Total -->
   <div class="order-total">
      <span class="total-label">Total</span>
       <span class="total-value">PHP <%# Eval("TotalAmount", "{0:N2}") %></span>
           </div>

           <!-- Action Buttons -->
              <div class="action-buttons">
   <asp:Button ID="btnApprove" runat="server" Text="? Approve" CssClass="btn-approve" 
        CommandName="Approve" CommandArgument='<%# Eval("OrderID") %>' OnClientClick="showLoading();" />
              <asp:Button ID="btnReject" runat="server" Text="? Reject" CssClass="btn-reject" 
       CommandName="Reject" CommandArgument='<%# Eval("OrderID") %>' OnClientClick="return confirmReject();" />
              </div>
     </div>
    </ItemTemplate>
          </asp:Repeater>

     <!-- Empty State -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
 <i class="bi bi-check-circle"></i>
       <h3>All Caught Up!</h3>
          <p>No pending orders waiting for approval</p>
     <a href="Dashboard.aspx">
       <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
    </a>
            </asp:Panel>
     </div>
    </form>
    
    <script src="Scripts/app.js"></script>
    <script>
        // Notification sound with repeat for staff attention
        function playNotificationSound() {
  try {
       var audio = document.getElementById('notificationSound');
              if (audio) {
        audio.volume = 0.7;
    audio.play().catch(function(error) {
          console.log("Audio playback requires user interaction first:", error);
           });
         }
      } catch (e) {
     console.log("Audio error:", e);
 }
        }
        
        function showLoading() {
            document.getElementById('loadingOverlay').classList.add('active');
            return true;
        }
        
        function confirmReject() {
            if (confirm('Are you sure you want to REJECT this order?')) {
      showLoading();
return true;
  }
            return false;
 }
        
        document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('loadingOverlay').classList.remove('active');
         
            // Get pending count
            var count = document.getElementById('<%= lblCount.ClientID %>').innerText;
            
            // Play sound if there are pending orders
      if (parseInt(count) > 0) {
                // Try to play immediately; also play on first user interaction if blocked
      playNotificationSound();
   document.addEventListener('click', function onFirstClick() {
 playNotificationSound();
     document.removeEventListener('click', onFirstClick);
 }, { once: true });
     
                // Add pulse animation to orders
        var cards = document.querySelectorAll('.order-card');
    cards.forEach(function(card, index) {
   setTimeout(function() {
             card.classList.add('notification-pulse');
       }, index * 200);
        });
            }

            // Auto-refresh every 15 seconds (reduced from 5s to prevent excessive refreshes)
      setInterval(function() {
       __doPostBack('', '');
}, 15000);
        });
    </script>
</body>
</html>
