module citesystem.rest.statusreturn;

/**
 * Data as return type for several API actions.
 */
package struct StatusReturn {
    /// HTTP return status.
    int status;
    /// Additional status message.
    string message;
}
