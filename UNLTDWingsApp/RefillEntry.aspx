<%@ Page Title="Log Refill" Language="C#" AutoEventWireup="true" CodeBehind="RefillEntry.aspx.cs" Inherits="UNLTDWingsApp.RefillEntry" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Log Refill - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
body { background-color:#F5F0EB; font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; min-height:100vh; }

/* Header */
.header { background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%); padding:15px 20px; display:flex; align-items:center; gap:15px; }
.back-btn { color:#5E2D10; font-size:1.5rem; text-decoration:none; }
.page-title { color:#5E2D10; font-size:18px; font-weight:700; flex:1; }
.refill-icon { background:white; width:40px; height:40px; border-radius:50%; display:flex; justify-content:center; align-items:center; }
.refill-icon i { color:#FF8C00; font-size:1.2rem; }

/* Content */
.content { padding:20px; }
.section { background:white; border-radius:15px; padding:20px; margin-bottom:15px; box-shadow:0 2px 8px rgba(0,0,0,0.05); opacity:0; animation: fadeInUp 0.4s ease forwards; }
.section:nth-child(1) { animation-delay:0.1s; }
.section:nth-child(2) { animation-delay:0.2s; }
.section-title { color:#5E2D10; font-size:15px; font-weight:700; margin-bottom:15px; display:flex; align-items:center; gap:8px; }

/* Form */
.form-label { color:#5E2D10; font-weight:600; font-size:14px; margin-bottom:8px; }
.form-control, .form-select { border:2px solid #E8D5B5; border-radius:10px; padding:12px 15px; font-size:14px; transition:border-color 0.3s ease; }
.form-control:focus, .form-select:focus { border-color:#FF8C00; box-shadow:0 0 0 2px rgba(255,140,0,0.1); }

/* Time Warning */
.time-warning { background:#FFF3E0; border:2px solid #FFB74D; border-radius:10px; padding:12px 15px; margin-top:15px; display:flex; align-items:center; gap:10px; }
.time-warning i { color:#FF8C00; font-size:1.2rem; }
.time-warning-text { font-size:13px; color:#5E2D10; }
.time-warning-text strong { color:#E65100; }

/* Submit Button */
.btn-submit { background: linear-gradient(135deg, #FF8C00 0%, #FF6B00 100%); color:white; border:none; border-radius:15px; padding:15px; font-size:16px; font-weight:700; width:100%; margin-top:20px; transition: all 0.3s ease; }
.btn-submit:hover { background: linear-gradient(135deg, #E67E00 0%, #E65100 100%); color:white; transform: translateY(-2px); }

/* Message */
.message { padding:12px; border-radius:10px; text-align:center; font-weight:600; margin-top:10px; animation: fadeInScale 0.3s ease forwards; }
.message.success { background:#d4edda; color:#155724; }
.message.error { background:#f8d7da; color:#721c24; }

/* Recent Refills */
.refill-item { display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-bottom:1px solid #F0E8E0; }
.refill-item:last-child { border-bottom:none; }
.refill-customer { font-weight:600; font-size:14px; color:#2C2C2C; }
.refill-details { font-size:12px; color:#888; }
.refill-time { font-size:12px; color:#FF8C00; font-weight:600; }

/* Flavor Buttons */
.flavor-options { display:flex; gap:10px; flex-wrap:wrap; }
.flavor-btn { padding:10px 20px; border:2px solid #E8D5B5; border-radius:25px; background:white; color:#5E2D10; font-weight:600; font-size:13px; cursor:pointer; transition: all 0.3s ease; }
.flavor-btn:hover { border-color:#FF8C00; transform: scale(1.05); }
.flavor-btn.active { background:#FF8C00; color:white; border-color:#FF8C00; }

@keyframes fadeInUp { from { opacity:0; transform: translateY(20px); } to { opacity:1; transform: translateY(0); } }
@keyframes fadeInScale { from { opacity:0; transform: scale(0.9); } to { opacity:1; transform: scale(1); } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
       <div style="text-align: center;">
     <div class="loading-spinner"></div>
   <div class="loading-text">Logging refill...</div>
     </div>
        </div>
        
        <!-- Header -->
   <div class="header">
  <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn">
<i class="bi bi-arrow-left"></i>
  </asp:LinkButton>
         <span class="page-title">Log Unlimited Refill</span>
        <div class="refill-icon">
         <i class="bi bi-arrow-repeat"></i>
            </div>
     </div>

        <!-- Content -->
     <div class="content">
            <!-- Refill Form -->
         <div class="section">
           <div class="section-title">
      <i class="bi bi-plus-circle-fill"></i>
      New Refill Entry
  </div>

        <div class="mb-3">
           <label class="form-label"><i class="bi bi-receipt me-2"></i>Select Active Order</label>
      <asp:DropDownList ID="ddlOrders" runat="server" CssClass="form-select">
       </asp:DropDownList>
    </div>

   <div class="mb-3">
 <label class="form-label"><i class="bi bi-droplet-fill me-2"></i>Select Flavor</label>
   <asp:HiddenField ID="hfSelectedFlavor" runat="server" Value="Fiery Buffalo" />
      <div class="flavor-options">
<div class="flavor-btn active" onclick="selectFlavor(this, 'Fiery Buffalo')">Fiery Buffalo</div>
 <div class="flavor-btn" onclick="selectFlavor(this, 'Sweet BBQ')">Sweet BBQ</div>
   <div class="flavor-btn" onclick="selectFlavor(this, 'Honey Garlic')">Honey Garlic</div>
               <div class="flavor-btn" onclick="selectFlavor(this, 'Garlic Parmesan')">Garlic Parmesan</div>
            <div class="flavor-btn" onclick="selectFlavor(this, 'Mango Habanero')">Mango Habanero</div>
     <div class="flavor-btn" onclick="selectFlavor(this, 'Garlic Mayo')">Garlic Mayo</div>
       </div>
                </div>

      <div class="mb-3">
   <label class="form-label"><i class="bi bi-123 me-2"></i>Quantity (Wings)</label>
   <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control" TextMode="Number" Text="6" min="1"></asp:TextBox>
                </div>

         <!-- Time Warning -->
    <div class="time-warning">
      <i class="bi bi-clock-history"></i>
       <div class="time-warning-text">
      <strong>Reminder:</strong> Unlimited dining limit is <strong>1 hour 30 minutes</strong>. Check order start time before serving additional refills.
          </div>
         </div>

       <asp:Button ID="btnLogRefill" runat="server" Text="Confirm Refill" CssClass="btn-submit" OnClick="btnLogRefill_Click" OnClientClick="showLoading();" />
          <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>
            </div>

    <!-- Recent Refills -->
            <div class="section">
    <div class="section-title">
  <i class="bi bi-clock-history"></i>
               Recent Refills Today
                </div>

      <asp:Repeater ID="rptRefills" runat="server">
              <ItemTemplate>
       <div class="refill-item">
        <div>
       <div class="refill-customer"><%# Eval("CustomerName") %></div>
             <div class="refill-details"><%# Eval("Flavor") %> - <%# Eval("Quantity") %> pcs</div>
        </div>
 <div class="refill-time"><%# Eval("RefillTime", "{0:hh:mm tt}") %></div>
       </div>
                 </ItemTemplate>
     </asp:Repeater>

   <asp:Panel ID="pnlNoRefills" runat="server" Visible="false">
         <div class="text-center text-muted py-3">
        <i class="bi bi-inbox d-block" style="font-size: 2rem;"></i>
       <p class="mb-0 mt-2">No refills logged today</p>
     </div>
  </asp:Panel>
            </div>
        </div>
  </form>

    <script src="Scripts/app.js"></script>
    <script>
        function selectFlavor(element, flavor) {
            // Remove active class from all
      document.querySelectorAll('.flavor-btn').forEach(btn => {
        btn.classList.remove('active');
      });
            // Add active to selected
element.classList.add('active');
       // Update hidden field
            document.getElementById('<%= hfSelectedFlavor.ClientID %>').value = flavor;
        }
        
        function showLoading() {
        document.getElementById('loadingOverlay').classList.add('active');
        }
        
        document.addEventListener('DOMContentLoaded', function() {
   document.getElementById('loadingOverlay').classList.remove('active');
    });
    </script>
</body>
</html>