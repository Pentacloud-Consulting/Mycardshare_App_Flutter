/**
 * Standard NEXUS API Response Envelope
 * Format strictly dictated:
 * { data: T | null, error: null | {code, message}, meta?: {} }
 */

const apiResponse = {
  /**
   * Standard success response
   * @param {*} data Base payload
   * @param {Object} [meta] Optional pagination/cursor/meta information
   */
  success: (data, meta = undefined) => {
    const response = {
      success: true,
      data: data !== undefined ? data : null,
      error: null,
    };
    if (meta) {
      response.meta = meta;
    }
    return response;
  },

  /**
   * Standard error response
   * @param {string} code Error code string (e.g. 'UNAUTHORIZED', 'NOT_FOUND')
   * @param {string} message Human readable messaging
   */
  fail: (code, message) => {
    return {
      success: false,
      data: null,
      error: {
        code,
        message,
      },
    };
  },
};

export const success = apiResponse.success;
export const fail = apiResponse.fail;
export default apiResponse;
