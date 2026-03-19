<%@ Page Title="QR Code Management" Language="C#" AutoEventWireup="true" CodeBehind="QRCodeManagement.aspx.cs" Inherits="UNLTDWingsApp.QRCodeManagement" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>QR Code Management - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
 body {
        background-color: #F5F0EB;
   font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
   min-height: 100vh;
        }
        .header {
 background: linear-gradient(135deg, #3D2314 0%, #5E2D10 100%);
    padding: 15px 20px;
    display: flex;
      align-items: center;
  gap: 15px;
        }
        .back-btn { color: white; font-size: 1.5rem; text-decoration: none; }
     .page-title { color: white; font-size: 18px; font-weight: 700; flex: 1; }
     .btn-add-new {
       background: #28a745;
         color: white;
     border: none;
       padding: 8px 15px;
  border-radius: 20px;
        font-size: 13px;
  font-weight: 600;
          transition: all 0.3s ease;
      }
        .btn-add-new:hover { background: #218838; color: white; transform: scale(1.05); }
        .content { padding: 20px; }
        .section {
         background: white;
      border-radius: 15px;
            padding: 20px;
      margin-bottom: 15px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
   animation: fadeInUp 0.4s ease forwards;
       opacity: 0;
        }
 .section:nth-child(1) { animation-delay: 0.1s; }
    .section:nth-child(2) { animation-delay: 0.2s; }
        .section-title {
            color: #5E2D10;
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
  gap: 8px;
        }
     .info-box {
   background: linear-gradient(135deg, #E3F2FD 0%, #BBDEFB 100%);
 border-left: 4px solid #2196F3;
            border-radius: 10px;
   padding: 15px;
     margin-bottom: 20px;
        }
      .info-box h6 { color: #1565C0; margin-bottom: 8px; font-weight: 700; }
        .info-box p { color: #1976D2; font-size: 13px; margin: 0; }
        .form-label { color: #5E2D10; font-weight: 600; font-size: 13px; margin-bottom: 5px; }
        .form-control, .form-select {
            border: 2px solid #E8D5B5;
            border-radius: 10px;
          padding: 10px 15px;
            font-size: 14px;
     transition: border-color 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
        border-color: #5E2D10;
      box-shadow: 0 0 0 2px rgba(94, 45, 16, 0.1);
        }
        .btn-save {
            background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
    color: white;
            border: none;
            border-radius: 10px;
     padding: 12px 25px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-save:hover { background: linear-gradient(135deg, #4a230c 0%, #6B3410 100%); color: white; transform: translateY(-2px); }
        .btn-cancel {
  background: #6c757d;
      color: white;
   border: none;
     border-radius: 10px;
          padding: 12px 25px;
font-weight: 600;
        }
        /* QR Code Card */
        .qr-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 15px;
        }
 .qr-card {
            background: white;
  border-radius: 15px;
            padding: 20px;
      text-align: center;
            border: 2px solid #E8D5B5;
         transition: all 0.3s ease;
        }
        .qr-card:hover {
   border-color: #5E2D10;
         transform: translateY(-3px);
   box-shadow: 0 8px 20px rgba(0,0,0,0.1);
 }
        .qr-card.inactive {
            opacity: 0.6;
            border-color: #dc3545;
        }
        .table-number {
            font-size: 36px;
            font-weight: 700;
          color: #5E2D10;
  margin-bottom: 5px;
        }
 .table-label {
            font-size: 14px;
      color: #888;
   margin-bottom: 15px;
    }
        .qr-preview {
  width: 150px;
        height: 150px;
            background: #F5F0EB;
        border-radius: 10px;
            display: flex;
      justify-content: center;
            align-items: center;
        margin: 0 auto 15px auto;
          overflow: hidden;
        }
        .qr-preview img {
  width: 100%;
          height: 100%;
    object-fit: contain;
        }
        .qr-preview i { font-size: 3rem; color: #D4C4B0; }
        .qr-url {
            font-size: 11px;
         color: #888;
            word-break: break-all;
            background: #F5F0EB;
     padding: 8px;
 border-radius: 8px;
          margin-bottom: 15px;
 }
 .qr-actions {
    display: flex;
       gap: 8px;
 justify-content: center;
        }
        .btn-sm {
  padding: 6px 12px;
         border-radius: 6px;
            font-size: 12px;
         font-weight: 600;
    border: none;
            cursor: pointer;
            transition: all 0.3s ease;
 }
        .btn-copy { background: #17a2b8; color: white; }
   .btn-copy:hover { background: #138496; }
        .btn-edit { background: #007bff; color: white; }
        .btn-edit:hover { background: #0056b3; }
        .btn-toggle { background: #ffc107; color: #333; }
        .btn-toggle:hover { background: #e0a800; }
        .btn-delete { background: #dc3545; color: white; }
   .btn-delete:hover { background: #c82333; }
   .status-badge {
            display: inline-block;
            padding: 4px 12px;
      border-radius: 15px;
            font-size: 11px;
        font-weight: 600;
            margin-bottom: 10px;
        }
        .status-active { background: #d4edda; color: #155724; }
        .status-inactive { background: #f8d7da; color: #721c24; }
        .message {
         padding: 12px;
  border-radius: 10px;
            text-align: center;
     font-weight: 600;
            margin-bottom: 15px;
            animation: fadeInScale 0.3s ease forwards;
        }
        .message.success { background: #d4edda; color: #155724; }
        .message.error { background: #f8d7da; color: #721c24; }
        .empty-state {
      text-align: center;
       padding: 40px;
            color: #888;
        }
        .empty-state i { font-size: 4rem; margin-bottom: 15px; color: #D4C4B0; }
  
        @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
  }
        @keyframes fadeInScale {
            from { opacity: 0; transform: scale(0.9); }
        to { opacity: 1; transform: scale(1); }
      }
    </style>
</head>
<body>
    <form id="form1" runat="server">
<!-- Loading Overlay -->
        <div id="loadingOverlay" class="loading-overlay">
     <div style="text-align: center;">
     <div class="loading-spinner"></div>
 <div class="loading-text">Processing...</div>
  </div>
  </div>
        
        <div class="header">
       <asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn">
            <i class="bi bi-arrow-left"></i>
          </asp:LinkButton>
       <span class="page-title">QR Code Management</span>
            <asp:Button ID="btnShowAdd" runat="server" Text="+ Add Table QR" CssClass="btn-add-new" OnClick="btnShowAdd_Click" />
</div>

        <div class="content">
    <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

    <!-- Info Box -->
            <div class="info-box">
         <h6><i class="bi bi-info-circle me-2"></i>How QR Codes Work</h6>
      <p>Each table has a unique QR code that guests can scan to access the ordering system. 
         Generate QR codes using any free QR generator (like qr-code-generator.com) with the URL provided, 
      then print and place on tables. Guests scan ? Enter name ? Browse menu ? Submit order ? Staff approves.</p>
            </div>

      <!-- Add/Edit Form -->
     <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="section">
     <div class="section-title">
      <i class="bi bi-qr-code"></i>
      <asp:Label ID="lblFormTitle" runat="server" Text="Add New Table QR Code"></asp:Label>
    </div>
<asp:HiddenField ID="hfQRCodeID" runat="server" Value="0" />
    
           <div class="row g-3">
     <div class="col-md-6">
   <label class="form-label">Table Number/Name *</label>
          <asp:TextBox ID="txtTableNumber" runat="server" CssClass="form-control" placeholder="e.g., 1, 2, A1, VIP-1" MaxLength="10"></asp:TextBox>
       </div>
     <div class="col-md-6">
          <label class="form-label">Table Description</label>
            <asp:TextBox ID="txtTableDescription" runat="server" CssClass="form-control" placeholder="e.g., Near window, 4 seater" MaxLength="100"></asp:TextBox>
              </div>
            <div class="col-12">
        <label class="form-label">Custom URL (Optional - leave blank for auto-generated)</label>
     <asp:TextBox ID="txtCustomUrl" runat="server" CssClass="form-control" placeholder="https://your-qr-image-url.com/qr.png"></asp:TextBox>
             <small class="text-muted">You can paste a link to a custom QR code image if you've generated one externally</small>
    </div>
           <div class="col-12">
         <div class="form-check">
    <asp:CheckBox ID="chkActive" runat="server" CssClass="form-check-input" Checked="true" />
          <label class="form-check-label">Active (guests can scan and order)</label>
     </div>
           </div>
        <div class="col-12 d-flex gap-2 mt-3">
<asp:Button ID="btnSave" runat="server" Text="Save Table QR" CssClass="btn-save" OnClick="btnSave_Click" />
       <asp:Button ID="btnCancelForm" runat="server" Text="Cancel" CssClass="btn-cancel" OnClick="btnCancelForm_Click" CausesValidation="false" />
        </div>
     </div>
    </asp:Panel>

    <!-- QR Codes Grid -->
            <div class="section">
<div class="section-title">
         <i class="bi bi-grid-3x3-gap"></i>
           Table QR Codes (<asp:Label ID="lblQRCount" runat="server" Text="0"></asp:Label>)
  </div>

  <div class="qr-grid">
                  <asp:Repeater ID="rptQRCodes" runat="server" OnItemCommand="rptQRCodes_ItemCommand">
    <ItemTemplate>
            <div class='<%# Convert.ToBoolean(Eval("IsActive")) ? "qr-card" : "qr-card inactive" %>'>
          <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "status-badge status-active" : "status-badge status-inactive" %>'>
          <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
     </span>
   <div class="table-number"><%# Eval("TableNumber") %></div>
         <div class="table-label"><%# string.IsNullOrEmpty(Eval("TableDescription").ToString()) ? "Table" : Eval("TableDescription") %></div>
           
        <div class="qr-preview">
             <%# !string.IsNullOrEmpty(Eval("QRImageUrl").ToString()) ? 
   "<img src='" + Eval("QRImageUrl") + "' alt='QR Code' onerror=\"this.style.display='none';this.nextElementSibling.style.display='block';\" /><i class='bi bi-qr-code' style='display:none;'></i>" : 
  "<i class='bi bi-qr-code'></i>" %>
 </div>
 
        <div class="qr-url" id="url_<%# Eval("QRCodeID") %>"><%# Eval("OrderUrl") %></div>
       
        <div class="qr-actions">
     <button type="button" class="btn-sm btn-copy" onclick="copyUrl('<%# Eval("OrderUrl") %>')">
        <i class="bi bi-clipboard"></i> Copy URL
       </button>
              <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn-sm btn-edit" 
        CommandName="Edit" CommandArgument='<%# Eval("QRCodeID") %>'>
            <i class="bi bi-pencil"></i>
       </asp:LinkButton>
    <asp:LinkButton ID="btnToggle" runat="server" CssClass="btn-sm btn-toggle" 
            CommandName="Toggle" CommandArgument='<%# Eval("QRCodeID") + "|" + Eval("IsActive") %>'
     ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>'>
    <i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "bi bi-pause-fill" : "bi bi-play-fill" %>'></i>
      </asp:LinkButton>
                <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn-sm btn-delete" 
   CommandName="Delete" CommandArgument='<%# Eval("QRCodeID") %>'
           OnClientClick="return confirm('Delete this QR code? This cannot be undone.');">
        <i class="bi bi-trash"></i>
             </asp:LinkButton>
           </div>
 </div>
     </ItemTemplate>
        </asp:Repeater>
          </div>

       <asp:Panel ID="pnlNoQRCodes" runat="server" Visible="false" CssClass="empty-state">
          <i class="bi bi-qr-code-scan d-block"></i>
               <h5>No Table QR Codes Yet</h5>
 <p>Click "+ Add Table QR" to create QR codes for your restaurant tables.</p>
         </asp:Panel>
</div>

            <!-- Instructions Section -->
  <div class="section">
    <div class="section-title">
                    <i class="bi bi-book"></i>
        How to Set Up Table QR Codes
         </div>
  <ol style="color: #5E2D10; font-size: 14px; line-height: 2;">
            <li><strong>Add a table</strong> - Click "+ Add Table QR" and enter the table number</li>
<li><strong>Copy the URL</strong> - Click "Copy URL" to get the ordering link</li>
         <li><strong>Generate QR Code</strong> - Go to <a href="https://www.qr-code-generator.com/" target="_blank" style="color: #007bff;">qr-code-generator.com</a> and paste the URL</li>
           <li><strong>Download & Print</strong> - Download the QR code image and print it</li>
        <li><strong>Place on Tables</strong> - Put the printed QR codes on each table</li>
         <li><strong>Guests Scan</strong> - Guests scan, enter their name, and start ordering!</li>
     </ol>
            </div>
        </div>
</form>

    <script src="Scripts/app.js"></script>
    <script>
        function copyUrl(url) {
       navigator.clipboard.writeText(url).then(function() {
   Toast.success('URL copied to clipboard!');
            }, function() {
                // Fallback for older browsers
                var textArea = document.createElement("textarea");
     textArea.value = url;
     document.body.appendChild(textArea);
                textArea.select();
       document.execCommand('copy');
   document.body.removeChild(textArea);
        Toast.success('URL copied to clipboard!');
   });
    }

        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('loadingOverlay').classList.remove('active');
        });
 </script>
</body>
</html>
