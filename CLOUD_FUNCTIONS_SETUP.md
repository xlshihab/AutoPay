# Cloud Functions Setup for Automatic Notifications

## Prerequisites
- Node.js installed
- Firebase CLI installed: `npm install -g firebase-tools`

## Setup Steps

### 1. Initialize Cloud Functions
```bash
cd /path/to/your/project
firebase init functions
```

Select:
- Use existing project (your Firebase project)
- JavaScript or TypeScript (your choice)
- Install dependencies

### 2. Install Dependencies
```bash
cd functions
npm install firebase-admin firebase-functions
```

### 3. Create Function Code

Edit `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Trigger on new transaction
exports.onNewTransaction = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const transactionId = context.params.transactionId;

    // Check if it's deposit, entry_fee, or withdraw
    if (!['deposit', 'entry_fee', 'withdraw'].includes(transaction.type)) {
      return null;
    }

    // Get all admin device tokens
    const tokensSnapshot = await admin.firestore()
      .collection('device_tokens')
      .get();

    const tokens = [];
    tokensSnapshot.forEach(doc => {
      if (doc.data().token) {
        tokens.push(doc.data().token);
      }
    });

    if (tokens.length === 0) {
      console.log('No device tokens found');
      return null;
    }

    // Prepare notification
    let title = '';
    let body = '';

    switch (transaction.type) {
      case 'deposit':
        title = '💰 New Deposit Request';
        break;
      case 'entry_fee':
        title = '🎮 New Entry Fee';
        break;
      case 'withdraw':
        title = '💸 New Withdrawal Request';
        break;
    }

    body = `Amount: ৳${transaction.amount}\n${transaction.description || ''}`;

    // Send notification to all devices
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: transaction.type,
        amount: transaction.amount.toString(),
        description: transaction.description || '',
        transactionId: transactionId,
        status: transaction.status || 'pending',
      },
      tokens: tokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log(`Successfully sent ${response.successCount} notifications`);
      
      if (response.failureCount > 0) {
        console.log(`Failed to send ${response.failureCount} notifications`);
        
        // Remove invalid tokens
        const tokensToRemove = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            tokensToRemove.push(tokens[idx]);
          }
        });

        // Clean up invalid tokens from Firestore
        for (const token of tokensToRemove) {
          const snapshot = await admin.firestore()
            .collection('device_tokens')
            .where('token', '==', token)
            .get();
          
          snapshot.forEach(async (doc) => {
            await doc.ref.delete();
          });
        }
      }

      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });
```

### 4. Deploy Cloud Function
```bash
firebase deploy --only functions
```

### 5. Test
Add a new transaction in Firestore with:
```json
{
  "type": "deposit",
  "amount": 500,
  "description": "Test deposit",
  "status": "pending",
  "createdAt": [current timestamp],
  "userId": "test123"
}
```

Notification should arrive automatically!

## Alternative: Manual Notification from Web App

If you want to send notifications manually from your web app:

```javascript
// Get device tokens
const tokensSnapshot = await firebase.firestore()
  .collection('device_tokens')
  .get();

const tokens = tokensSnapshot.docs.map(doc => doc.data().token);

// Call Cloud Function or use Admin SDK
const response = await fetch('https://fcm.googleapis.com/fcm/send', {
  method: 'POST',
  headers: {
    'Authorization': 'key=YOUR_SERVER_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    registration_ids: tokens,
    notification: {
      title: '💰 New Deposit',
      body: 'Amount: ৳500',
    },
    data: {
      type: 'deposit',
      amount: '500',
    },
  }),
});
```

## Firestore Structure

### device_tokens collection:
```
device_tokens/
  admin_device/
    token: "fcm_token_here"
    updatedAt: timestamp
    platform: "android"
```

### For multiple admins:
```
device_tokens/
  user_123/
    token: "fcm_token_1"
    userId: "user_123"
    role: "admin"
  user_456/
    token: "fcm_token_2"
    userId: "user_456"
    role: "admin"
```

## Testing Locally

1. Install Firebase Functions Emulator:
```bash
firebase emulators:start
```

2. Test locally before deploying

## Troubleshooting

- **No notification received:** Check Firebase Console → Cloud Messaging → Logs
- **Token not saved:** Check device_tokens collection in Firestore
- **Function error:** Check Firebase Console → Functions → Logs
- **Permission denied:** Check Firestore security rules

## Security Rules

Make sure Firestore rules allow reading tokens:
```javascript
match /device_tokens/{tokenId} {
  allow read, write: if request.auth != null;
}
```
