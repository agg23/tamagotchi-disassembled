/**
 * Logs an error message with a line number and message
 * @param message The error message to display
 * @param lineNumber The one-based index of the line that generated the error
 */
export const log = (message: String, lineNumber: Number) =>
  console.log(`ERROR (line ${lineNumber}): ${message}`);
