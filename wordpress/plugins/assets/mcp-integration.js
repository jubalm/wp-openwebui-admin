/**
 * MCP Integration Plugin JavaScript
 * Handles frontend interactions for MCP communication
 */

(function($) {
    'use strict';
    
    // MCP Integration object
    var MCPIntegration = {
        
        init: function() {
            this.bindEvents();
            this.addMCPStatus();
        },
        
        bindEvents: function() {
            // Add any frontend event handlers here
            $(document).ready(function() {
                console.log('MCP Integration Plugin loaded');
            });
        },
        
        addMCPStatus: function() {
            // Add MCP status indicator to admin bar if user is logged in
            if (typeof mcp_ajax !== 'undefined') {
                this.checkMCPStatus();
            }
        },
        
        checkMCPStatus: function() {
            $.ajax({
                url: mcp_ajax.rest_url + 'status',
                method: 'GET',
                success: function(response) {
                    console.log('MCP Plugin Status:', response);
                },
                error: function(xhr, status, error) {
                    console.error('MCP Status Check Failed:', error);
                }
            });
        },
        
        // Helper function to make MCP API calls
        apiCall: function(endpoint, method, data, callback) {
            var settings = {
                url: mcp_ajax.rest_url + endpoint,
                method: method || 'GET',
                headers: {
                    'X-WP-Nonce': mcp_ajax.nonce,
                    'Content-Type': 'application/json'
                },
                success: callback || function(response) {
                    console.log('MCP API Response:', response);
                },
                error: function(xhr, status, error) {
                    console.error('MCP API Error:', error);
                }
            };
            
            if (data && (method === 'POST' || method === 'PUT')) {
                settings.data = JSON.stringify(data);
            }
            
            $.ajax(settings);
        }
    };
    
    // Initialize when document is ready
    $(document).ready(function() {
        MCPIntegration.init();
    });
    
    // Make MCPIntegration available globally
    window.MCPIntegration = MCPIntegration;
    
})(jQuery);