/**
 * DistroMap API - Frontend Application
 * =====================================
 */

(function() {
  'use strict';

  // ============================================
  // Theme Toggle
  // ============================================
  const ThemeManager = {
    init() {
      this.toggle = document.getElementById('themeToggle');
      this.html = document.documentElement;
      
      // Load saved theme or default to dark
      const savedTheme = localStorage.getItem('theme') || 'dark';
      this.setTheme(savedTheme);
      
      // Bind event
      if (this.toggle) {
        this.toggle.addEventListener('click', () => this.toggleTheme());
      }
    },

    setTheme(theme) {
      this.html.setAttribute('data-theme', theme);
      localStorage.setItem('theme', theme);
    },

    toggleTheme() {
      const currentTheme = this.html.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      this.setTheme(newTheme);
    }
  };

  // ============================================
  // Status Bar
  // ============================================
  const StatusManager = {
    elements: {},
    refreshInterval: 30000, // 30 seconds

    init() {
      this.elements = {
        indicator: document.getElementById('statusIndicator'),
        productCount: document.getElementById('productCount'),
        uptime: document.getElementById('uptimeDisplay'),
        productBadge: document.getElementById('productBadge')
      };

      this.fetchStatus();
      setInterval(() => this.fetchStatus(), this.refreshInterval);
    },

    async fetchStatus() {
      try {
        const response = await fetch('/health');
        const data = await response.json();
        this.updateUI(data);
      } catch (error) {
        this.showOffline();
      }
    },

    updateUI(data) {
      if (!this.elements.indicator) return;

      if (data.status === 'healthy') {
        this.elements.indicator.innerHTML = 
          '<span class="status-dot online"></span><span class="status-text">Online</span>';
      } else {
        this.elements.indicator.innerHTML = 
          '<span class="status-dot offline"></span><span class="status-text">Issues</span>';
      }

      if (this.elements.productCount && data.database?.product_count) {
        this.elements.productCount.textContent = data.database.product_count + ' products';
      }

      if (this.elements.uptime && data.uptime) {
        this.elements.uptime.textContent = 'Up: ' + data.uptime;
      }

      if (this.elements.productBadge && data.database?.product_count) {
        this.elements.productBadge.textContent = '📦 ' + data.database.product_count + '+ Products';
      }
    },

    showOffline() {
      if (this.elements.indicator) {
        this.elements.indicator.innerHTML = 
          '<span class="status-dot offline"></span><span class="status-text">Offline</span>';
      }
    }
  };

  // ============================================
  // Clipboard Manager
  // ============================================
  const ClipboardManager = {
    init() {
      document.querySelectorAll('.copy-btn').forEach(btn => {
        btn.addEventListener('click', (e) => this.handleCopy(e, btn));
      });
    },

    async handleCopy(event, btn) {
      event.preventDefault();
      event.stopPropagation();

      let textToCopy = btn.getAttribute('data-copy');

      // Check if copying from a target element
      const targetId = btn.getAttribute('data-copy-target');
      if (targetId) {
        const target = document.getElementById(targetId);
        if (target) {
          textToCopy = target.textContent;
        }
      }

      if (!textToCopy) return;

      // Try modern clipboard API first, fallback to execCommand
      try {
        if (navigator.clipboard && window.isSecureContext) {
          await navigator.clipboard.writeText(textToCopy);
        } else {
          this.fallbackCopy(textToCopy);
        }
        this.showSuccess(btn);
      } catch (err) {
        // Try fallback method
        try {
          this.fallbackCopy(textToCopy);
          this.showSuccess(btn);
        } catch (fallbackErr) {
          this.showError(btn);
        }
      }
    },

    fallbackCopy(text) {
      const textArea = document.createElement('textarea');
      textArea.value = text;
      textArea.style.position = 'fixed';
      textArea.style.left = '-9999px';
      textArea.style.top = '-9999px';
      document.body.appendChild(textArea);
      textArea.focus();
      textArea.select();
      
      const successful = document.execCommand('copy');
      document.body.removeChild(textArea);
      
      if (!successful) {
        throw new Error('Fallback copy failed');
      }
    },

    showSuccess(btn) {
      const originalText = btn.textContent;
      btn.textContent = '✅ Copied!';
      btn.classList.add('copied');
      
      setTimeout(() => {
        btn.textContent = originalText;
        btn.classList.remove('copied');
      }, 2000);
    },

    showError(btn) {
      const originalText = btn.textContent;
      btn.textContent = '❌ Failed';
      
      setTimeout(() => {
        btn.textContent = originalText;
      }, 2000);
    }
  };

  // ============================================
  // API Search / Try It
  // ============================================
  const SearchManager = {
    elements: {},
    // Valid input pattern matching server-side validation
    VALID_INPUT_PATTERN: /^[a-zA-Z0-9._-]+$/,

    init() {
      this.elements = {
        searchBtn: document.getElementById('searchBtn'),
        productInput: document.getElementById('productInput'),
        codenameInput: document.getElementById('codenameInput'),
        responseContainer: document.getElementById('responseContainer'),
        responseOutput: document.getElementById('responseOutput')
      };

      this.bindEvents();
    },

    bindEvents() {
      // Search button
      if (this.elements.searchBtn) {
        this.elements.searchBtn.addEventListener('click', () => this.performSearch());
      }

      // Enter key support
      [this.elements.productInput, this.elements.codenameInput].forEach(input => {
        if (input) {
          input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.performSearch();
          });
        }
      });

      // Quick links
      document.querySelectorAll('.quick-btn').forEach(btn => {
        btn.addEventListener('click', () => {
          if (this.elements.productInput) {
            this.elements.productInput.value = btn.getAttribute('data-product') || '';
          }
          if (this.elements.codenameInput) {
            this.elements.codenameInput.value = btn.getAttribute('data-codename') || '';
          }
          this.performSearch();
        });
      });
    },

    /**
     * Validate input against allowed pattern
     * @param {string} value - The value to validate
     * @param {string} fieldName - Name of the field for error messages
     * @returns {boolean} True if valid, false otherwise
     */
    validateInput(value, fieldName) {
      if (!value) {
        return true; // Empty is allowed (handled separately)
      }
      if (!this.VALID_INPUT_PATTERN.test(value)) {
        this.showError(`Invalid ${fieldName}: only letters, numbers, dots, hyphens, and underscores are allowed`);
        return false;
      }
      return true;
    },

    async performSearch() {
      const product = this.elements.productInput?.value.trim();
      const codename = this.elements.codenameInput?.value.trim();

      if (!product) {
        this.showError('Please enter a product name');
        return;
      }

      // Validate inputs before making request
      if (!this.validateInput(product, 'product name')) {
        return;
      }
      if (codename && !this.validateInput(codename, 'codename')) {
        return;
      }

      this.setLoading(true);

      try {
        let url = '/distro/' + encodeURIComponent(product);
        if (codename) {
          url += '/' + encodeURIComponent(codename);
        }

        const response = await fetch(url);
        const data = await response.json();

        this.showResponse(JSON.stringify(data, null, 2));
      } catch (error) {
        this.showResponse('Error: ' + error.message);
      } finally {
        this.setLoading(false);
      }
    },

    setLoading(isLoading) {
      if (this.elements.searchBtn) {
        this.elements.searchBtn.textContent = isLoading ? 'Loading...' : 'Search';
        this.elements.searchBtn.disabled = isLoading;
      }
    },

    showResponse(content) {
      if (this.elements.responseContainer) {
        this.elements.responseContainer.style.display = 'block';
      }
      if (this.elements.responseOutput) {
        this.elements.responseOutput.textContent = content;
      }
      
      // Scroll to response
      this.elements.responseContainer?.scrollIntoView({ 
        behavior: 'smooth', 
        block: 'nearest' 
      });
    },

    showError(message) {
      alert(message);
    }
  };

  // ============================================
  // Initialize on DOM Ready
  // ============================================
  function init() {
    ThemeManager.init();
    StatusManager.init();
    ClipboardManager.init();
    SearchManager.init();
  }

  // Run when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
