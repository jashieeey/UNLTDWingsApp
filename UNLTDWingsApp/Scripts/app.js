/* =============================================
   UNLTD Wings - Application JavaScript
   Version 2.0 - Enhanced UX
   ============================================= */

// =============================================
// Loading Overlay Functions
// =============================================
const AppLoader = {
    overlay: null,
    
    init: function() {
        // Create loading overlay if it doesn't exist
        if (!document.getElementById('loadingOverlay')) {
            const overlay = document.createElement('div');
      overlay.id = 'loadingOverlay';
            overlay.className = 'loading-overlay';
    overlay.innerHTML = `
<div style="text-align: center;">
  <div class="loading-spinner"></div>
            <div class="loading-text">Please wait...</div>
  </div>
    `;
            document.body.appendChild(overlay);
        }
 this.overlay = document.getElementById('loadingOverlay');
  },
    
    show: function(message = 'Please wait...') {
        if (!this.overlay) this.init();
        const textEl = this.overlay.querySelector('.loading-text');
        if (textEl) textEl.textContent = message;
        this.overlay.classList.add('active');
    },
    
    hide: function() {
        if (this.overlay) {
     this.overlay.classList.remove('active');
        }
    }
};

// =============================================
// Toast Notification Functions
// =============================================
const Toast = {
  container: null,
    
    init: function() {
      if (!document.getElementById('toastContainer')) {
       const container = document.createElement('div');
          container.id = 'toastContainer';
   container.className = 'toast-container';
            document.body.appendChild(container);
        }
 this.container = document.getElementById('toastContainer');
    },
    
    show: function(message, type = 'success', duration = 3000) {
    if (!this.container) this.init();
   
   const toast = document.createElement('div');
        toast.className = `toast-notification ${type}`;
        
        let icon = 'bi-check-circle-fill';
        if (type === 'error') icon = 'bi-x-circle-fill';
        else if (type === 'warning') icon = 'bi-exclamation-triangle-fill';
        else if (type === 'info') icon = 'bi-info-circle-fill';
        
        toast.innerHTML = `<i class="bi ${icon}"></i>${message}`;
        this.container.appendChild(toast);
        
        // Trigger animation
        setTimeout(() => toast.classList.add('show'), 10);
        
        // Remove after duration
        setTimeout(() => {
      toast.classList.remove('show');
   setTimeout(() => toast.remove(), 300);
     }, duration);
    },
    
    success: function(message, duration) {
        this.show(message, 'success', duration);
    },
    
    error: function(message, duration) {
        this.show(message, 'error', duration);
    },
    
    warning: function(message, duration) {
      this.show(message, 'warning', duration);
    },
    
    info: function(message, duration) {
        this.show(message, 'info', duration);
    }
};

// =============================================
// Button Loading State
// =============================================
const ButtonLoader = {
    setLoading: function(button, loading = true, text = 'Processing...') {
        if (loading) {
        button.dataset.originalText = button.textContent || button.innerText;
   button.disabled = true;
            button.classList.add('btn-loading');
     button.innerHTML = `<span class="btn-spinner"></span>${text}`;
    } else {
            button.disabled = false;
            button.classList.remove('btn-loading');
            button.innerHTML = button.dataset.originalText || 'Submit';
      }
    }
};

// =============================================
// Format Currency (PHP)
// =============================================
function formatCurrency(amount, useSymbol = true) {
    const num = parseFloat(amount) || 0;
    if (useSymbol) {
        return 'PHP ' + num.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }
    return num.toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

// =============================================
// Animate Elements on Scroll/Load
// =============================================
function animateOnLoad() {
  const elements = document.querySelectorAll('[data-animate]');
    elements.forEach((el, index) => {
        el.style.opacity = '0';
        setTimeout(() => {
el.classList.add('animate-fade-in-up');
     el.style.opacity = '1';
      }, index * 100);
  });
}

// =============================================
// Form Validation Helper
// =============================================
const FormValidator = {
    validateRequired: function(input) {
    const value = input.value.trim();
        if (!value) {
    this.showError(input, 'This field is required');
       return false;
        }
        this.clearError(input);
    return true;
    },
    
    validateNumber: function(input, min = 0, max = Infinity) {
 const value = parseFloat(input.value);
        if (isNaN(value) || value < min || value > max) {
            this.showError(input, `Please enter a valid number between ${min} and ${max}`);
return false;
      }
 this.clearError(input);
  return true;
    },
    
    showError: function(input, message) {
input.classList.add('is-invalid');
        let errorEl = input.parentElement.querySelector('.invalid-feedback');
        if (!errorEl) {
errorEl = document.createElement('div');
      errorEl.className = 'invalid-feedback';
   input.parentElement.appendChild(errorEl);
        }
        errorEl.textContent = message;
    },
    
    clearError: function(input) {
   input.classList.remove('is-invalid');
        const errorEl = input.parentElement.querySelector('.invalid-feedback');
        if (errorEl) errorEl.remove();
    }
};

// =============================================
// Image URL Helpers (Web Images)
// =============================================
const MenuImages = {
    // High-quality food images from Unsplash (free to use)
    getImageUrl: function(category, itemName) {
        const categoryImages = {
          'Unlimited': 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=400&h=300&fit=crop',
 'Wings': 'https://images.unsplash.com/photo-1608039755401-742074f0548d?w=400&h=300&fit=crop',
       'Rice Meals': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=300&fit=crop',
            'Pasta': 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400&h=300&fit=crop',
     'Combos': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
 'Fries': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&h=300&fit=crop',
            'Drinks': 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&h=300&fit=crop',
 'Add-ons': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop'
        };
   
  return categoryImages[category] || categoryImages['Wings'];
    },
    
    // Fallback to gradient placeholder
    getPlaceholderClass: function(category) {
const classes = {
            'Unlimited': 'unlimited',
  'Wings': 'wings',
         'Rice Meals': 'rice-meals',
            'Pasta': 'pasta',
   'Combos': 'combos',
            'Fries': 'fries',
         'Drinks': 'drinks',
       'Add-ons': 'add-ons'
  };
  return classes[category] || 'wings';
    },
    
    getCategoryIcon: function(category) {
        const icons = {
            'Unlimited': 'bi-infinity',
            'Wings': 'bi-fire',
            'Rice Meals': 'bi-egg-fried',
            'Pasta': 'bi-cup-hot',
  'Combos': 'bi-box2-fill',
      'Fries': 'bi-basket-fill',
            'Drinks': 'bi-cup-straw',
 'Add-ons': 'bi-plus-circle-fill'
        };
        return icons[category] || 'bi-circle-fill';
    }
};

// =============================================
// Auto-hide loading on page load
// =============================================
document.addEventListener('DOMContentLoaded', function() {
    AppLoader.init();
    Toast.init();
 animateOnLoad();
    
    // Hide loading after content loads
    setTimeout(() => AppLoader.hide(), 100);
});

// =============================================
// Show loading on ASP.NET postback
// =============================================
if (typeof Sys !== 'undefined' && Sys.WebForms) {
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(function() {
    AppLoader.show('Processing...');
    });
    
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
        AppLoader.hide();
        animateOnLoad();
});
}

// =============================================
// Show loading on form submit
// =============================================
document.addEventListener('submit', function(e) {
    const form = e.target;
    // Only show for non-async forms
    if (!form.dataset.noLoader) {
        AppLoader.show('Processing...');
    }
});

// =============================================
// Confirm before dangerous actions
// =============================================
function confirmAction(message) {
    return confirm(message || 'Are you sure you want to continue?');
}

// =============================================
// Debounce function for search inputs
// =============================================
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
            clearTimeout(timeout);
   func(...args);
        };
 clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}
