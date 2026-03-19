<%@ Page Title="Account Management" Language="C#" AutoEventWireup="true" CodeBehind="AccountManagement.aspx.cs" Inherits="UNLTDWingsApp.AccountManagement" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Account Management - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
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
    }
     .content { padding: 20px; }
  .section {
            background: white;
    border-radius: 15px;
    padding: 20px;
 margin-bottom: 15px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
   }
    .section-title {
    color: #5E2D10;
     font-size: 16px;
   font-weight: 700;
           margin-bottom: 15px;
     display: flex;
 align-items: center;
            gap: 8px;
        }
.form-label {
     color: #5E2D10;
      font-weight: 600;
        font-size: 13px;
   margin-bottom: 5px;
  }
   .form-control, .form-select {
           border: 2px solid #E8D5B5;
        border-radius: 10px;
         padding: 10px 15px;
          font-size: 14px;
  }
     .form-control:focus, .form-select:focus {
 border-color: #5E2D10;
  box-shadow: 0 0 0 2px rgba(94, 45, 16, 0.1);
      }
   .btn-save {
   background: #5E2D10;
      color: white;
     border: none;
   border-radius: 10px;
 padding: 12px 25px;
    font-weight: 600;
    }
    .btn-save:hover { background: #4a230c; color: white; }
      .btn-cancel {
   background: #6c757d;
       color: white;
    border: none;
    border-radius: 10px;
padding: 12px 25px;
          font-weight: 600;
  }
        .user-row {
    display: flex;
   align-items: center;
   padding: 15px 0;
          border-bottom: 1px solid #F0E8E0;
      gap: 15px;
        }
        .user-row:last-child { border-bottom: none; }
     .user-avatar {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
   border-radius: 50%;
          display: flex;
        justify-content: center;
         align-items: center;
         flex-shrink: 0;
    }
   .user-avatar i { color: white; font-size: 1.5rem; }
 .user-details { flex: 1; }
 .user-name { font-weight: 600; font-size: 15px; color: #2C2C2C; }
    .user-username { font-size: 12px; color: #888; }
       .role-badge {
            padding: 5px 15px;
   border-radius: 15px;
   font-size: 12px;
     font-weight: 600;
     }
  .role-admin { background: #5E2D10; color: white; }
        .role-staff { background: #E8D5B5; color: #5E2D10; }
    .user-actions { display: flex; gap: 8px; }
     .btn-edit {
    background: #007bff;
       color: white;
 border: none;
     padding: 6px 12px;
      border-radius: 6px;
        font-size: 12px;
        }
        .btn-delete {
      background: #dc3545;
  color: white;
     border: none;
  padding: 6px 12px;
 border-radius: 6px;
            font-size: 12px;
  }
        .message {
 padding: 12px;
      border-radius: 10px;
  text-align: center;
  font-weight: 600;
  margin-bottom: 15px;
 }
      .message.success { background: #d4edda; color: #155724; }
        .message.error { background: #f8d7da; color: #721c24; }
        .password-hint {
            font-size: 11px;
       color: #888;
 margin-top: 5px;
        }
    </style>
</head>
<body>
 <form id="form1" runat="server">
   <div class="header">
<asp:LinkButton ID="btnBack" runat="server" OnClick="btnBack_Click" CssClass="back-btn">
     <i class="bi bi-arrow-left"></i>
    </asp:LinkButton>
         <span class="page-title">Account Management</span>
        <asp:Button ID="btnShowAdd" runat="server" Text="+ Add User" CssClass="btn-add-new" OnClick="btnShowAdd_Click" />
</div>

        <div class="content">
  <asp:Label ID="lblMessage" runat="server" CssClass="message" Visible="false"></asp:Label>

       <!-- Add/Edit Form -->
       <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="section">
           <div class="section-title">
    <i class="bi bi-person-plus"></i>
    <asp:Label ID="lblFormTitle" runat="server" Text="Add New User"></asp:Label>
  </div>
      <asp:HiddenField ID="hfUserID" runat="server" Value="0" />
 
<div class="row g-3">
         <div class="col-12">
  <label class="form-label">Full Name *</label>
     <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter full name" MaxLength="100"></asp:TextBox>
  </div>
  <div class="col-6">
  <label class="form-label">Username *</label>
       <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter username" MaxLength="50"></asp:TextBox>
   </div>
    <div class="col-6">
      <label class="form-label">Role *</label>
       <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
     <asp:ListItem Text="Staff" Value="Staff"></asp:ListItem>
         <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
  </asp:DropDownList>
 </div>
   <div class="col-12">
  <label class="form-label">Password <asp:Label ID="lblPasswordNote" runat="server" Text="*"></asp:Label></label>
      <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" placeholder="Enter password" TextMode="Password" MaxLength="255"></asp:TextBox>
              <div class="password-hint">Minimum 8 characters required</div>
    </div>
   <div class="col-12 d-flex gap-2 mt-3">
<asp:Button ID="btnSave" runat="server" Text="Save User" CssClass="btn-save" OnClick="btnSave_Click" />
     <asp:Button ID="btnCancelForm" runat="server" Text="Cancel" CssClass="btn-cancel" OnClick="btnCancelForm_Click" CausesValidation="false" />
  </div>
   </div>
       </asp:Panel>

     <!-- Users List -->
   <div class="section">
        <div class="section-title">
 <i class="bi bi-people"></i>
 User Accounts (<asp:Label ID="lblUserCount" runat="server" Text="0"></asp:Label>)
  </div>

               <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
        <ItemTemplate>
       <div class="user-row">
<div class="user-avatar">
      <i class="bi bi-person"></i>
          </div>
     <div class="user-details">
          <div class="user-name"><%# Eval("Name") %></div>
 <div class="user-username">@<%# Eval("Username") %></div>
    </div>
     <span class='<%# Eval("Role").ToString() == "Admin" ? "role-badge role-admin" : "role-badge role-staff" %>'>
      <%# Eval("Role") %>
  </span>
    <div class="user-actions">
  <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn-edit" CommandName="Edit" CommandArgument='<%# Eval("UserID") %>'>
   <i class="bi bi-pencil"></i> Edit
           </asp:LinkButton>
  <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn-delete" CommandName="Delete" 
    CommandArgument='<%# Eval("UserID") %>' 
     OnClientClick="return confirm('Are you sure you want to delete this user?');"
     Visible='<%# Eval("UserID").ToString() != Session["UserID"]?.ToString() %>'>
    <i class="bi bi-trash"></i>
    </asp:LinkButton>
  </div>
    </div>
       </ItemTemplate>
   </asp:Repeater>

         <asp:Panel ID="pnlNoUsers" runat="server" Visible="false">
       <div class="text-center py-4 text-muted">
<i class="bi bi-people d-block" style="font-size: 3rem;"></i>
    <p>No users found</p>
    </div>
     </asp:Panel>
   </div>
 </div>
  </form>
</body>
</html>
