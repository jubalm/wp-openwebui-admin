<?php
/**
 * Plugin Name: MCP Integration Plugin
 * Plugin URI: https://github.com/jubalm/wp-openwebui-admin
 * Description: Model Context Protocol integration for WordPress to enable communication with OpenWebUI
 * Version: 1.0.0
 * Author: IONOS PoC Team
 * License: MIT
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

class MCPIntegrationPlugin
{
    private $version = '1.0.0';
    
    public function __construct()
    {
        add_action('init', array($this, 'init'));
        add_action('rest_api_init', array($this, 'register_rest_routes'));
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
    }
    
    public function init()
    {
        // Initialize plugin
        $this->define_constants();
        $this->includes();
    }
    
    private function define_constants()
    {
        define('MCP_PLUGIN_VERSION', $this->version);
        define('MCP_PLUGIN_URL', plugin_dir_url(__FILE__));
        define('MCP_PLUGIN_PATH', plugin_dir_path(__FILE__));
    }
    
    private function includes()
    {
        // Include necessary files
    }
    
    public function enqueue_scripts()
    {
        wp_enqueue_script('mcp-integration', MCP_PLUGIN_URL . 'assets/mcp-integration.js', array('jquery'), MCP_PLUGIN_VERSION, true);
        wp_localize_script('mcp-integration', 'mcp_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('mcp_nonce'),
            'rest_url' => rest_url('mcp/v1/')
        ));
    }
    
    public function register_rest_routes()
    {
        // Register REST API endpoints for MCP communication
        
        // Get posts
        register_rest_route('mcp/v1', '/posts', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_posts'),
            'permission_callback' => array($this, 'check_permissions')
        ));
        
        // Create post
        register_rest_route('mcp/v1', '/posts', array(
            'methods' => 'POST',
            'callback' => array($this, 'create_post'),
            'permission_callback' => array($this, 'check_permissions')
        ));
        
        // Update post
        register_rest_route('mcp/v1', '/posts/(?P<id>\d+)', array(
            'methods' => 'PUT',
            'callback' => array($this, 'update_post'),
            'permission_callback' => array($this, 'check_permissions')
        ));
        
        // Delete post
        register_rest_route('mcp/v1', '/posts/(?P<id>\d+)', array(
            'methods' => 'DELETE',
            'callback' => array($this, 'delete_post'),
            'permission_callback' => array($this, 'check_permissions')
        ));
        
        // Get plugin status
        register_rest_route('mcp/v1', '/status', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_status'),
            'permission_callback' => '__return_true'
        ));
    }
    
    public function check_permissions($request)
    {
        // For PoC, we'll use basic authentication
        // In production, implement proper OAuth or API key authentication
        return current_user_can('edit_posts') || $this->verify_api_key($request);
    }
    
    private function verify_api_key($request)
    {
        $api_key = $request->get_header('X-API-Key');
        $stored_key = get_option('mcp_api_key', 'demo-api-key-poc');
        return $api_key === $stored_key;
    }
    
    public function get_posts($request)
    {
        $posts = get_posts(array(
            'numberposts' => $request->get_param('per_page') ?: 10,
            'offset' => $request->get_param('offset') ?: 0,
            'post_status' => 'publish'
        ));
        
        $formatted_posts = array();
        foreach ($posts as $post) {
            $formatted_posts[] = array(
                'id' => $post->ID,
                'title' => $post->post_title,
                'content' => $post->post_content,
                'excerpt' => $post->post_excerpt,
                'status' => $post->post_status,
                'date' => $post->post_date,
                'modified' => $post->post_modified,
                'author' => get_the_author_meta('display_name', $post->post_author),
                'permalink' => get_permalink($post->ID)
            );
        }
        
        return rest_ensure_response($formatted_posts);
    }
    
    public function create_post($request)
    {
        $params = $request->get_json_params();
        
        $post_data = array(
            'post_title' => sanitize_text_field($params['title'] ?? ''),
            'post_content' => wp_kses_post($params['content'] ?? ''),
            'post_excerpt' => sanitize_text_field($params['excerpt'] ?? ''),
            'post_status' => sanitize_text_field($params['status'] ?? 'draft'),
            'post_type' => 'post'
        );
        
        $post_id = wp_insert_post($post_data);
        
        if (is_wp_error($post_id)) {
            return new WP_Error('post_creation_failed', 'Failed to create post', array('status' => 500));
        }
        
        $post = get_post($post_id);
        return rest_ensure_response(array(
            'id' => $post->ID,
            'title' => $post->post_title,
            'content' => $post->post_content,
            'status' => $post->post_status,
            'permalink' => get_permalink($post->ID),
            'message' => 'Post created successfully'
        ));
    }
    
    public function update_post($request)
    {
        $post_id = $request->get_param('id');
        $params = $request->get_json_params();
        
        $post_data = array(
            'ID' => $post_id,
            'post_title' => sanitize_text_field($params['title'] ?? ''),
            'post_content' => wp_kses_post($params['content'] ?? ''),
            'post_excerpt' => sanitize_text_field($params['excerpt'] ?? ''),
            'post_status' => sanitize_text_field($params['status'] ?? 'draft')
        );
        
        $result = wp_update_post($post_data);
        
        if (is_wp_error($result)) {
            return new WP_Error('post_update_failed', 'Failed to update post', array('status' => 500));
        }
        
        $post = get_post($post_id);
        return rest_ensure_response(array(
            'id' => $post->ID,
            'title' => $post->post_title,
            'content' => $post->post_content,
            'status' => $post->post_status,
            'permalink' => get_permalink($post->ID),
            'message' => 'Post updated successfully'
        ));
    }
    
    public function delete_post($request)
    {
        $post_id = $request->get_param('id');
        
        $result = wp_delete_post($post_id, true);
        
        if (!$result) {
            return new WP_Error('post_deletion_failed', 'Failed to delete post', array('status' => 500));
        }
        
        return rest_ensure_response(array(
            'id' => $post_id,
            'message' => 'Post deleted successfully'
        ));
    }
    
    public function get_status($request)
    {
        return rest_ensure_response(array(
            'plugin' => 'MCP Integration Plugin',
            'version' => MCP_PLUGIN_VERSION,
            'status' => 'active',
            'wordpress_version' => get_bloginfo('version'),
            'endpoints' => array(
                'GET /mcp/v1/posts' => 'Get posts',
                'POST /mcp/v1/posts' => 'Create post',
                'PUT /mcp/v1/posts/{id}' => 'Update post',
                'DELETE /mcp/v1/posts/{id}' => 'Delete post',
                'GET /mcp/v1/status' => 'Get plugin status'
            ),
            'authentication' => 'API Key (X-API-Key header) or WordPress user authentication'
        ));
    }
}

// Initialize the plugin
new MCPIntegrationPlugin();

// Activation hook
register_activation_hook(__FILE__, function() {
    // Set default API key for PoC
    add_option('mcp_api_key', 'demo-api-key-poc');
    
    // Flush rewrite rules
    flush_rewrite_rules();
});

// Deactivation hook
register_deactivation_hook(__FILE__, function() {
    flush_rewrite_rules();
});