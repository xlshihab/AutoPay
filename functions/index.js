const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();

/**
 * Sends push notification when a new transaction is created
 * Triggers on: transactions/{transactionId} onCreate
 */
exports.onNewTransaction = onDocumentCreated(
    "transactions/{transactionId}",
    async (event) => {
      try {
        // Get the newly created transaction data
        const transaction = event.data.data();
        const transactionId = event.params.transactionId;

        logger.info("New transaction detected:", {
          id: transactionId,
          type: transaction.type,
          amount: transaction.amount,
        });

        // Get all device tokens for admin
        const db = getFirestore();
        const tokensSnapshot = await db
            .collection("device_tokens")
            .doc("admin_device")
            .get();

        if (!tokensSnapshot.exists) {
          logger.warn("No device tokens found");
          return null;
        }

        const tokensData = tokensSnapshot.data();
        const tokens = tokensData.tokens || [];

        if (tokens.length === 0) {
          logger.warn("Device tokens array is empty");
          return null;
        }

        logger.info(`Sending notification to ${tokens.length} device(s)`);

        // Create FCM message with full transaction details from Firestore
        const message = {
          data: {
            type: transaction.type || "",
            transactionId: transactionId,
            amount: (transaction.amount || 0).toString(),
            userName: transaction.description || "Unknown User",
            phoneNumber: transaction.phoneNumber || "",
            trxId: transaction.transactionId || "",
            method: transaction.paymentMethod || "",
            status: transaction.status || "pending",
            paymentDocId: transaction.paymentDocId || "",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          tokens: tokens,
        };

        // Send multicast message
        const response = await getMessaging().sendEachForMulticast(message);

        logger.info(`Successfully sent ${response.successCount} notifications`);

        // Handle failed tokens
        if (response.failureCount > 0) {
          const failedTokens = [];
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              failedTokens.push(tokens[idx]);
              logger.error(`Failed to send to token ${idx}:`, resp.error);
            }
          });

          // Remove invalid tokens
          if (failedTokens.length > 0) {
            const validTokens = tokens.filter((t) => !failedTokens.includes(t));
            await db.collection("device_tokens").doc("admin_device").update({
              tokens: validTokens,
            });
            logger.info(`Removed ${failedTokens.length} invalid tokens`);
          }
        }

        return {success: true, sent: response.successCount};
      } catch (error) {
        logger.error("Error sending notification:", error);
        return {success: false, error: error.message};
      }
    },
);
