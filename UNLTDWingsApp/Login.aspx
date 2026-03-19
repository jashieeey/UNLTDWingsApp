<%@ Page Title="Login" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="UNLTDWingsApp.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - UNLTD Wings</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
 <link href="Content/app-styles.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .login-container {
            width: 100%;
            max-width: 420px;
            padding: 20px;
            opacity: 0;
            animation: fadeIn 0.6s ease forwards;
        }
        
        .form-control {
            background: rgba(200, 200, 200, 0.5);
            border: 2px solid #ddd;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            background: rgba(255, 255, 255, 0.9);
            border-color: #5E2D10;
            box-shadow: 0 0 0 3px rgba(94, 45, 16, 0.1);
        }
        
        .input-group { position: relative; }
        .input-group .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #666;
            cursor: pointer;
            z-index: 10;
        }
        
        .form-switch { padding-left: 2.5em; }
        .form-switch .form-check-input {
            width: 40px;
            height: 20px;
            background-color: #ccc;
            border: none;
            cursor: pointer;
        }
        .form-switch .form-check-input:checked { background-color: #5E2D10; }
        .form-check-label { color: #f3f3f3; font-size:13px; }
        
        .btn-login {
            background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 14px;
            font-size: 16px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }
        .btn-login:hover {
            background: linear-gradient(135deg, #4a230c 0%, #6B3410 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(94, 45, 16, 0.4);
        }
        
        .btn-guest {
            background: transparent;
            color: #5E2D10;
            border: 2px solid #5E2D10;
            border-radius: 25px;
            padding: 12px;
            font-size: 14px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }
        .btn-guest:hover {
            background: rgba(94, 45, 16, 0.1);
            color: #5E2D10;
            transform: translateY(-2px);
        }
        
        .demo-box {
            background: rgba(0,0,0,0.25);
            border-radius:15px;
            padding:15px;
            margin-top:15px;
        }
        .demo-box h6 {
            color: #ffffff;
            font-size: 12px;
            font-weight: 700;
            text-align: center;
            margin-bottom: 10px;
        }
        .demo-account {
            background: linear-gradient(135deg, #5E2D10 0%, #8B4513 100%);
            color: white;
            border-radius: 20px;
            padding: 10px 15px;
            font-size: 12px;
            text-align: center;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .demo-account:last-child { margin-bottom: 0; }
        .demo-account i { font-size: 14px; }
        
        .error-message {
            background: rgba(220, 53, 69, 0.1);
            color: #dc3545;
            padding: 12px;
            border-radius: 10px;
            font-size: 13px;
            text-align: center;
            animation: shake 0.5s ease-in-out;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="unltd-login-bg">
            <!-- Loading Overlay -->
            <div id="loadingOverlay" class="loading-overlay">
                <div style="text-align: center;">
                    <div class="loading-spinner"></div>
                    <div class="loading-text">Signing in...</div>
                </div>
            </div>
          
            <div class="login-container">
                <!-- Logo -->
                <div class="text-center mb-3">
                    <div class="unltd-logo-circle">
                        <div class="text-center lh-1" style="color: #FFD700; font-weight: bold; font-size: 14px;">
                            <span class="d-block fs-4"><i class="bi bi-fire"></i></span>
                            UNLTD<br/>WINGS
                        </div>
                    </div>
                </div>

                <!-- Avatar -->
                <div class="unltd-avatar-circle">
                    <i class="bi bi-person-fill fs-1 text-secondary"></i>
                </div>

                <!-- Login Panel -->
                <div class="unltd-glass-panel" style="background: rgba(255,255,255,0.60); backdrop-filter: blur(12px);">
                    <!-- Username -->
                    <div class="mb-3">
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Username"></asp:TextBox>
                    </div>

                    <!-- Password -->
                    <div class="mb-3 input-group">
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Password"></asp:TextBox>
                        <button type="button" class="toggle-password" onclick="togglePassword()">
                            <i class="bi bi-eye" id="eyeIcon"></i>
                        </button>
                    </div>

                    <!-- Remember Me -->
                    <div class="form-check form-switch mb-3">
                        <input class="form-check-input" type="checkbox" id="rememberMe" runat="server">
                        <label class="form-check-label" for="rememberMe">Remember Me</label>
                    </div>

                    <!-- Error Message -->
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="error-message mb-3">
                        <i class="bi bi-exclamation-circle me-2"></i>
                        <asp:Label ID="lblError" runat="server"></asp:Label>
                    </asp:Panel>

                    <!-- Login Button -->
                    <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn-login mb-3" OnClick="btnLogin_Click" OnClientClick="showLoading();" />

                    <!-- Continue as Guest Button -->
                    <asp:Button ID="btnGuest" runat="server" Text="Continue as Guest" CssClass="btn-guest" OnClick="btnGuest_Click" CausesValidation="false" />
                    <div style="font-size:12px; color: rgba(255,255,255,0.9); margin-top:8px; text-align:center;">
                        <i class="bi bi-info-circle me-1"></i>
                        Guest checkout is for <strong>Take-out</strong> &amp; <strong>Delivery</strong> only. For dine-in, use a table account below.
                    </div>

                    <!-- Demo Accounts -->
                    <div class="demo-box">
                        <h6><i class="bi bi-info-circle me-1"></i>Demo Accounts</h6>
                        <div class="demo-account">
                            <i class="bi bi-shield-lock-fill"></i>
                            Admin: admin / admin123
                        </div>
                        <div class="demo-account">
                            <i class="bi bi-person-badge-fill"></i>
                            Staff: staff / staff123
                        </div>
                        <div class="demo-account" style="flex-direction:column; gap:4px;">
                            <div><i class="bi bi-table me-1"></i>Table Accounts (Dine-in)</div>
                            <div style="font-size:11px; opacity:0.85;">Table1 / Table1 &nbsp;&bull;&nbsp; Table2 / Table2 &nbsp;&bull;&nbsp; Table3 / Table3</div>
                            <div style="font-size:11px; opacity:0.85;">Table4 / Table4 &nbsp;&bull;&nbsp; Table5 / Table5</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="Scripts/app.js"></script>
    <script>
      function togglePassword() {
       var passwordField = document.getElementById('<%= txtPassword.ClientID %>');
            var eyeIcon = document.getElementById('eyeIcon');
            
 if (passwordField.type === 'password') {
     passwordField.type = 'text';
             eyeIcon.className = 'bi bi-eye-slash';
            } else {
        passwordField.type = 'password';
    eyeIcon.className = 'bi bi-eye';
            }
        }
        
    function showLoading() {
          document.getElementById('loadingOverlay').classList.add('active');
        }
        
        document.addEventListener('DOMContentLoaded', function() {
        if(typeof AppLoader !== 'undefined') AppLoader.hide();
        document.getElementById('loadingOverlay').classList.remove('active');
        });
 </script>
</body>
</html>