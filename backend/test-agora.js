import pkg from 'agora-access-token';
const { RtcTokenBuilder, RtcRole } = pkg;
import dotenv from 'dotenv';
dotenv.config();

const appId = '1a72ae2630224062a6192784611ffce6';
const appCertificate = 'a3b05ed3f48c414d8cb8bd4a13195395';
const channelName = 'test_channel';
const uid = 0;
const role = RtcRole.PUBLISHER;
const expirationTimeInSeconds = 3600;
const currentTimestamp = Math.floor(Date.now() / 1000);
const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

try {
    const token = RtcTokenBuilder.buildTokenWithUid(
        appId,
        appCertificate,
        channelName,
        uid,
        role,
        privilegeExpiredTs
    );
    console.log('Token generated successfully:', token);
} catch (error) {
    console.error('Error generating token:', error);
}
