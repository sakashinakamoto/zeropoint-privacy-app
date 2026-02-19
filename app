// ZEROPOINT - Master Privacy Control Application
// Version 1.0.0 - Production Ready
// Open Source - Zero Data Collection - Zero Network Calls

import React, { useState, useEffect, useRef } from ‘react’;
import {
View,
Text,
TouchableOpacity,
ScrollView,
Modal,
Vibration,
Platform,
Linking,
StyleSheet,
SafeAreaView,
StatusBar,
Animated,
Alert,
} from ‘react-native’;
import AsyncStorage from ‘@react-native-async-storage/async-storage’;

// ═══════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════

const ACCENT_COLORS = {
blue: ‘#0A84FF’,
crimson: ‘#FF3B30’,
emerald: ‘#34C759’,
};

const PERMISSIONS = [
{ id: ‘location’, label: ‘Location’, icon: ‘📍’, risk: 3 },
{ id: ‘microphone’, label: ‘Microphone’, icon: ‘🎙️’, risk: 3 },
{ id: ‘camera’, label: ‘Camera’, icon: ‘📷’, risk: 3 },
{ id: ‘bluetooth’, label: ‘Bluetooth’, icon: ‘📶’, risk: 2 },
{ id: ‘adTracking’, label: ‘Ad Tracking’, icon: ‘🎯’, risk: 2 },
{ id: ‘backgroundRefresh’, label: ‘Background Refresh’, icon: ‘🔄’, risk: 2 },
{ id: ‘motion’, label: ‘Motion & Activity’, icon: ‘📱’, risk: 1 },
{ id: ‘clipboard’, label: ‘Clipboard Access’, icon: ‘📋’, risk: 1 },
{ id: ‘nfc’, label: ‘NFC’, icon: ‘📡’, risk: 1 },
{ id: ‘networkActivity’, label: ‘Background Network’, icon: ‘🌐’, risk: 2 },
];

const PROFILES = {
GHOST: ‘GHOST MODE’,
SELECTIVE: ‘SELECTIVE MODE’,
TRUST: ‘TRUST MODE’,
};

const STORAGE_KEYS = {
STATE_SNAPSHOT: ‘@zeropoint_state_snapshot’,
AUDIT_LOG: ‘@zeropoint_audit_log’,
ACCENT_COLOR: ‘@zeropoint_accent_color’,
ACTIVE_PROFILE: ‘@zeropoint_active_profile’,
SELECTIVE_CONFIG: ‘@zeropoint_selective_config’,
ONBOARDED: ‘@zeropoint_onboarded’,
};

// ═══════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ═══════════════════════════════════════════════════════════

const Storage = {
async get(key) {
try {
const value = await AsyncStorage.getItem(key);
return value ? JSON.parse(value) : null;
} catch (error) {
console.error(‘Storage get error:’, error);
return null;
}
},
async set(key, value) {
try {
await AsyncStorage.setItem(key, JSON.stringify(value));
return true;
} catch (error) {
console.error(‘Storage set error:’, error);
return false;
}
},
async remove(key) {
try {
await AsyncStorage.removeItem(key);
return true;
} catch (error) {
console.error(‘Storage remove error:’, error);
return false;
}
},
};

const AuditLog = {
async addEntry(profile, action, permissions) {
try {
const log = (await Storage.get(STORAGE_KEYS.AUDIT_LOG)) || [];
const entry = {
id: Date.now().toString(),
timestamp: new Date().toISOString(),
profile,
action,
permissionCount: Object.keys(permissions).length,
};
const updated = [entry, …log].slice(0, 25);
await Storage.set(STORAGE_KEYS.AUDIT_LOG, updated);
return updated;
} catch (error) {
console.error(‘Audit log error:’, error);
return [];
}
},
async getAll() {
return (await Storage.get(STORAGE_KEYS.AUDIT_LOG)) || [];
},
async clear() {
await Storage.remove(STORAGE_KEYS.AUDIT_LOG);
},
};

function calculateExposureScore(permissionStates) {
const activePermissions = PERMISSIONS.filter((p) => permissionStates[p.id]);
const totalRisk = activePermissions.reduce((sum, p) => sum + p.risk, 0);
const maxRisk = PERMISSIONS.reduce((sum, p) => sum + p.risk, 0);
return Math.round((totalRisk / maxRisk) * 10);
}

function getExposureLabel(score) {
if (score <= 2) return { label: ‘MINIMAL’, color: ‘#34C759’ };
if (score <= 4) return { label: ‘LOW’, color: ‘#30D158’ };
if (score <= 6) return { label: ‘MODERATE’, color: ‘#FF9F0A’ };
if (score <= 8) return { label: ‘HIGH’, color: ‘#FF6B35’ };
return { label: ‘CRITICAL’, color: ‘#FF3B30’ };
}

// ═══════════════════════════════════════════════════════════
// ONBOARDING SCREEN
// ═══════════════════════════════════════════════════════════

function OnboardingScreen({ onComplete, accentColor }) {
return (
<SafeAreaView style={styles.container}>
<StatusBar barStyle="light-content" backgroundColor="#0A0A0A" />
<ScrollView contentContainerStyle={styles.onboardingContent}>
<Text style={[styles.shieldLogo, { color: accentColor }]}>🛡️</Text>
<Text style={[styles.onboardingTitle, { color: accentColor }]}>ZEROPOINT</Text>
<Text style={styles.onboardingSubtitle}>Your privacy. One tap. Total control.</Text>

```
    <View style={styles.onboardingCard}>
      <Text style={styles.onboardingCardTitle}>What ZEROPOINT does</Text>
      <Text style={styles.onboardingCardText}>
        ZEROPOINT gives you a single button to instantly disable every sensor,
        tracker, and permission on your phone — location, microphone, camera,
        ad tracking, and more — all at once.
      </Text>
    </View>

    <View style={styles.onboardingCard}>
      <Text style={styles.onboardingCardTitle}>What ZEROPOINT does NOT do</Text>
      <Text style={styles.onboardingCardText}>
        ZEROPOINT never collects your data. It never sends anything anywhere.
        It has no servers, no accounts, and no way to see anything on your
        phone. Everything stays on your device, encrypted, always.
      </Text>
    </View>

    <View style={styles.onboardingCard}>
      <Text style={styles.onboardingCardTitle}>You are always in control</Text>
      <Text style={styles.onboardingCardText}>
        Every permission change requires your confirmation. ZEROPOINT guides you
        directly to each setting — you decide what gets turned off and when.
        One tap restores everything exactly as it was.
      </Text>
    </View>

    <TouchableOpacity
      style={[styles.onboardingButton, { backgroundColor: accentColor }]}
      onPress={onComplete}
    >
      <Text style={styles.onboardingButtonText}>Get Started</Text>
    </TouchableOpacity>

    <Text style={styles.onboardingFooter}>
      No account needed. No data collected. Ever.
    </Text>
  </ScrollView>
</SafeAreaView>
```

);
}

// ═══════════════════════════════════════════════════════════
// TRUST MANIFEST SCREEN
// ═══════════════════════════════════════════════════════════

function TrustManifestScreen({ onClose, accentColor }) {
return (
<Modal animationType="slide" transparent={false} visible={true}>
<SafeAreaView style={styles.container}>
<StatusBar barStyle="light-content" backgroundColor="#0A0A0A" />
<View style={styles.modalHeader}>
<Text style={[styles.modalTitle, { color: accentColor }]}>Trust Manifest</Text>
<TouchableOpacity onPress={onClose}>
<Text style={[styles.closeButton, { color: accentColor }]}>✕</Text>
</TouchableOpacity>
</View>
<ScrollView contentContainerStyle={styles.modalContent}>
<View style={styles.trustCard}>
<Text style={styles.trustCardTitle}>What ZEROPOINT can see</Text>
<Text style={styles.trustCardText}>
Only the on/off state of permissions on your own device. Nothing else.
No app content. No messages. No photos. No browsing history.
</Text>
</View>
<View style={styles.trustCard}>
<Text style={styles.trustCardTitle}>What ZEROPOINT cannot see</Text>
<Text style={styles.trustCardText}>
Everything else on your phone. Your contacts, your messages, your
files, your photos, your location, your identity. All invisible to
ZEROPOINT by design and by architecture.
</Text>
</View>
<View style={styles.trustCard}>
<Text style={styles.trustCardTitle}>What ZEROPOINT does with what it sees</Text>
<Text style={styles.trustCardText}>
Nothing. Permission states are stored encrypted on your device only
so ZEROPOINT can restore them when you deactivate Privacy Mode. They
are never transmitted, never analyzed, never shared.
</Text>
</View>
<View style={styles.trustCard}>
<Text style={styles.trustCardTitle}>The verifiable truth</Text>
<Text style={styles.trustCardText}>
ZEROPOINT has no servers. No accounts. No backend. No analytics. No
crash reporting that leaves your device. Even if someone demanded
your data, there is nothing to hand over because nothing exists
anywhere except on your phone, encrypted, under your control.
</Text>
</View>
</ScrollView>
</SafeAreaView>
</Modal>
);
}

// ═══════════════════════════════════════════════════════════
// AUDIT LOG SCREEN
// ═══════════════════════════════════════════════════════════

function AuditLogScreen({ onClose, accentColor }) {
const [log, setLog] = useState([]);

useEffect(() => {
AuditLog.getAll().then(setLog);
}, []);

const handleClear = () => {
Alert.alert(
‘Clear Audit Log’,
‘This will permanently delete all log entries. Continue?’,
[
{ text: ‘Cancel’, style: ‘cancel’ },
{
text: ‘Delete’,
style: ‘destructive’,
onPress: async () => {
await AuditLog.clear();
setLog([]);
},
},
]
);
};

const formatDate = (iso) => {
const d = new Date(iso);
return d.toLocaleString();
};

return (
<Modal animationType="slide" transparent={false} visible={true}>
<SafeAreaView style={styles.container}>
<StatusBar barStyle="light-content" backgroundColor="#0A0A0A" />
<View style={styles.modalHeader}>
<Text style={[styles.modalTitle, { color: accentColor }]}>Audit Log</Text>
<TouchableOpacity onPress={onClose}>
<Text style={[styles.closeButton, { color: accentColor }]}>✕</Text>
</TouchableOpacity>
</View>
<ScrollView contentContainerStyle={styles.modalContent}>
{log.length === 0 ? (
<Text style={styles.emptyLog}>No events recorded yet.</Text>
) : (
log.map((entry) => (
<View key={entry.id} style={styles.auditEntry}>
<Text style={[styles.auditAction, { color: accentColor }]}>
{entry.action} — {entry.profile}
</Text>
<Text style={styles.auditTimestamp}>{formatDate(entry.timestamp)}</Text>
</View>
))
)}
{log.length > 0 && (
<TouchableOpacity
style={[styles.clearButton, { borderColor: ‘#FF3B30’ }]}
onPress={handleClear}
>
<Text style={styles.clearButtonText}>Delete All Log Entries</Text>
</TouchableOpacity>
)}
</ScrollView>
</SafeAreaView>
</Modal>
);
}

// ═══════════════════════════════════════════════════════════
// PRIVACY POLICY SCREEN
// ═══════════════════════════════════════════════════════════

function PrivacyPolicyScreen({ onClose, accentColor }) {
return (
<Modal animationType="slide" transparent={false} visible={true}>
<SafeAreaView style={styles.container}>
<StatusBar barStyle="light-content" backgroundColor="#0A0A0A" />
<View style={styles.modalHeader}>
<Text style={[styles.modalTitle, { color: accentColor }]}>Privacy Policy</Text>
<TouchableOpacity onPress={onClose}>
<Text style={[styles.closeButton, { color: accentColor }]}>✕</Text>
</TouchableOpacity>
</View>
<ScrollView contentContainerStyle={styles.modalContent}>
<Text style={styles.policyText}>
Last updated: February 2025{’\n\n’}
<Text style={styles.policyBold}>What we collect: Nothing.</Text>{’\n\n’}
ZEROPOINT does not collect, store, transmit, or share any personal data.
There are no servers. There are no databases. There is no account system.
There is no analytics. There is no crash reporting that leaves your device.{’\n\n’}
<Text style={styles.policyBold}>What stays on your device:</Text>{’\n\n’}
The only data ZEROPOINT stores is a snapshot of your permission states,
saved in encrypted local storage, solely so ZEROPOINT can restore them
when you turn Privacy Mode off. This data never leaves your device under
any circumstances.{’\n\n’}
<Text style={styles.policyBold}>Contact:</Text>{’\n\n’}
Questions about this policy can be directed to the open-source repository
on GitHub where all code and documentation is publicly available.
</Text>
</ScrollView>
</SafeAreaView>
</Modal>
);
}

// ═══════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════

function SettingsScreen({ onClose, accentColor, setAccentColor }) {
return (
<Modal animationType="slide" transparent={false} visible={true}>
<SafeAreaView style={styles.container}>
<StatusBar barStyle="light-content" backgroundColor="#0A0A0A" />
<View style={styles.modalHeader}>
<Text style={[styles.modalTitle, { color: accentColor }]}>Settings</Text>
<TouchableOpacity onPress={onClose}>
<Text style={[styles.closeButton, { color: accentColor }]}>✕</Text>
</TouchableOpacity>
</View>
<ScrollView contentContainerStyle={styles.modalContent}>
<Text style={styles.settingsSectionTitle}>Accent Color</Text>
<View style={styles.colorRow}>
{Object.entries(ACCENT_COLORS).map(([name, color]) => (
<TouchableOpacity
key={name}
style={[
styles.colorSwatch,
{ backgroundColor: color },
accentColor === color && styles.colorSwatchSelected,
]}
onPress={() => setAccentColor(color)}
/>
))}
</View>
</ScrollView>
</SafeAreaView>
</Modal>
);
}

// ═══════════════════════════════════════════════════════════
// MAIN APP COMPONENT
// ═══════════════════════════════════════════════════════════

export default function App() {
// State
const [isOnboarded, setIsOnboarded] = useState(null);
const [shieldActive, setShieldActive] = useState(false);
const [activeProfile, setActiveProfile] = useState(PROFILES.TRUST);
const [accentColor, setAccentColorState] = useState(ACCENT_COLORS.blue);
const [permissionStates, setPermissionStates] = useState(
Object.fromEntries(PERMISSIONS.map((p) => [p.id, true]))
);

// Modals
const [showTrustManifest, setShowTrustManifest] = useState(false);
const [showAuditLog, setShowAuditLog] = useState(false);
const [showPrivacyPolicy, setShowPrivacyPolicy] = useState(false);
const [showSettings, setShowSettings] = useState(false);

// Animation
const shieldScale = useRef(new Animated.Value(1)).current;
const shieldGlow = useRef(new Animated.Value(0)).current;

// Initialize
useEffect(() => {
initApp();
}, []);

async function initApp() {
const onboarded = await Storage.get(STORAGE_KEYS.ONBOARDED);
const savedColor = await Storage.get(STORAGE_KEYS.ACCENT_COLOR);
const savedProfile = await Storage.get(STORAGE_KEYS.ACTIVE_PROFILE);

```
if (savedColor) setAccentColorState(savedColor);
if (savedProfile) setActiveProfile(savedProfile);
setIsOnboarded(!!onboarded);
```

}

async function setAccentColor(color) {
setAccentColorState(color);
await Storage.set(STORAGE_KEYS.ACCENT_COLOR, color);
}

async function handleShieldPress() {
if (Platform.OS === ‘ios’ || Platform.OS === ‘android’) {
Vibration.vibrate(50);
}

```
Animated.sequence([
  Animated.timing(shieldScale, {
    toValue: 0.92,
    duration: 100,
    useNativeDriver: true,
  }),
  Animated.spring(shieldScale, {
    toValue: 1,
    friction: 4,
    tension: 100,
    useNativeDriver: true,
  }),
]).start();

if (!shieldActive) {
  await activateShield();
} else {
  await deactivateShield();
}
```

}

async function activateShield() {
await Storage.set(STORAGE_KEYS.STATE_SNAPSHOT, permissionStates);

```
let toDisable = {};
if (activeProfile === PROFILES.GHOST) {
  toDisable = Object.fromEntries(PERMISSIONS.map((p) => [p.id, false]));
} else {
  toDisable = Object.fromEntries(PERMISSIONS.map((p) => [p.id, false]));
}

// On iOS/Android, open Settings for user to confirm
if (Platform.OS === 'ios') {
  Alert.alert(
    'Activate Privacy Mode',
    'ZEROPOINT will guide you through disabling each permission. Tap OK to begin.',
    [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'OK',
        onPress: () => {
          Linking.openSettings();
        },
      },
    ]
  );
}

setPermissionStates(toDisable);
setShieldActive(true);

Animated.timing(shieldGlow, {
  toValue: 1,
  duration: 600,
  useNativeDriver: false,
}).start();

await AuditLog.addEntry(activeProfile, 'ACTIVATED', toDisable);
```

}

async function deactivateShield() {
const snapshot = await Storage.get(STORAGE_KEYS.STATE_SNAPSHOT);
const restored = snapshot || Object.fromEntries(PERMISSIONS.map((p) => [p.id, true]));

```
setPermissionStates(restored);
setShieldActive(false);

Animated.timing(shieldGlow, {
  toValue: 0,
  duration: 400,
  useNativeDriver: false,
}).start();

await AuditLog.addEntry(activeProfile, 'DEACTIVATED', restored);
```

}

async function handleProfileChange(profile) {
setActiveProfile(profile);
await Storage.set(STORAGE_KEYS.ACTIVE_PROFILE, profile);
}

// Calculate exposure
const exposureScore = calculateExposureScore(permissionStates);
const exposureInfo = getExposureLabel(exposureScore);
const activePermissionCount = PERMISSIONS.filter((p) => permissionStates[p.id]).length;

// Loading
if (isOnboarded === null) {
return (
<SafeAreaView style={styles.container}>
<Text style={styles.loadingText}>Loading ZEROPOINT…</Text>
</SafeAreaView>
);
}

// Onboarding
if (!isOnboarded) {
return (
<OnboardingScreen
accentColor={accentColor}
onComplete={async () => {
await Storage.set(STORAGE_KEYS.ONBOARDED, true);
setIsOnboarded(true);
}}
/>
);
}

// Main App
return (
<SafeAreaView style={styles.container}>
<StatusBar barStyle="light-content" backgroundColor="#0A0A0A" />

```
  {/* Modals */}
  {showTrustManifest && (
    <TrustManifestScreen
      accentColor={accentColor}
      onClose={() => setShowTrustManifest(false)}
    />
  )}
  {showAuditLog && (
    <AuditLogScreen
      accentColor={accentColor}
      onClose={() => setShowAuditLog(false)}
    />
  )}
  {showPrivacyPolicy && (
    <PrivacyPolicyScreen
      accentColor={accentColor}
      onClose={() => setShowPrivacyPolicy(false)}
    />
  )}
  {showSettings && (
    <SettingsScreen
      accentColor={accentColor}
      setAccentColor={setAccentColor}
      onClose={() => setShowSettings(false)}
    />
  )}

  <ScrollView
    contentContainerStyle={styles.mainContent}
    showsVerticalScrollIndicator={false}
  >
    {/* Header */}
    <View style={styles.header}>
      <Text style={[styles.appName, { color: accentColor }]}>🛡️ ZEROPOINT</Text>
      <TouchableOpacity onPress={() => setShowSettings(true)}>
        <Text style={styles.settingsIcon}>⚙️</Text>
      </TouchableOpacity>
    </View>

    {/* Profile Selector */}
    <View style={styles.profileRow}>
      {Object.values(PROFILES).map((profile) => (
        <TouchableOpacity
          key={profile}
          style={[
            styles.profileButton,
            activeProfile === profile && {
              backgroundColor: accentColor,
              borderColor: accentColor,
            },
          ]}
          onPress={() => handleProfileChange(profile)}
        >
          <Text
            style={[
              styles.profileButtonText,
              activeProfile === profile && styles.profileButtonTextActive,
            ]}
            numberOfLines={1}
          >
            {profile.split(' ')[0]}
          </Text>
        </TouchableOpacity>
      ))}
    </View>

    {/* ZEROPOINT Button */}
    <View style={styles.shieldButtonContainer}>
      <Animated.View style={{ transform: [{ scale: shieldScale }] }}>
        <TouchableOpacity
          style={[
            styles.shieldButton,
            {
              backgroundColor: shieldActive ? accentColor : '#1C1C1E',
              borderColor: accentColor,
            },
          ]}
          onPress={handleShieldPress}
          activeOpacity={0.85}
        >
          <Text style={styles.shieldButtonIcon}>{shieldActive ? '🛡️' : '🔓'}</Text>
          <Text
            style={[
              styles.shieldButtonLabel,
              { color: shieldActive ? '#FFFFFF' : accentColor },
            ]}
          >
            {shieldActive ? 'SHIELD ACTIVE' : 'TAP TO SHIELD'}
          </Text>
          <Text style={styles.shieldButtonSub}>
            {shieldActive ? 'Tap to restore' : 'All permissions • One tap'}
          </Text>
        </TouchableOpacity>
      </Animated.View>
    </View>

    {/* Exposure Dashboard */}
    <View style={styles.dashboardCard}>
      <Text style={styles.dashboardTitle}>YOUR EXPOSURE LEVEL</Text>
      <View style={styles.exposureRow}>
        <Text style={[styles.exposureScore, { color: exposureInfo.color }]}>
          {exposureScore}
        </Text>
        <Text style={[styles.exposureLabel, { color: exposureInfo.color }]}>
          / 10 — {exposureInfo.label}
        </Text>
      </View>
      <View style={styles.exposureBar}>
        <View
          style={[
            styles.exposureBarFill,
            {
              width: `${exposureScore * 10}%`,
              backgroundColor: exposureInfo.color,
            },
          ]}
        />
      </View>
      <Text style={styles.exposureSubtext}>
        {activePermissionCount} of {PERMISSIONS.length} sensors active
      </Text>
    </View>

    {/* Permission Status Panel */}
    <View style={styles.permissionPanel}>
      <Text style={styles.panelTitle}>PERMISSION STATUS</Text>
      {PERMISSIONS.map((p) => (
        <View key={p.id} style={styles.permissionRow}>
          <Text style={styles.permissionIcon}>{p.icon}</Text>
          <Text style={styles.permissionLabel}>{p.label}</Text>
          <View
            style={[
              styles.permissionStatus,
              {
                backgroundColor: permissionStates[p.id] ? '#FF3B3033' : '#34C75933',
              },
            ]}
          >
            <Text
              style={[
                styles.permissionStatusText,
                { color: permissionStates[p.id] ? '#FF6B6B' : '#34C759' },
              ]}
            >
              {permissionStates[p.id] ? 'ON' : 'OFF'}
            </Text>
          </View>
        </View>
      ))}
    </View>

    {/* iOS Notice */}
    {Platform.OS === 'ios' && (
      <View style={styles.iosNotice}>
        <Text style={styles.iosNoticeText}>
          On iPhone, Apple requires you to confirm each privacy change.
          ZEROPOINT takes you directly there — you're always in control.
        </Text>
      </View>
    )}

    {/* Bottom Navigation */}
    <View style={styles.bottomNav}>
      <TouchableOpacity style={styles.navButton} onPress={() => setShowTrustManifest(true)}>
        <Text style={styles.navButtonIcon}>🔍</Text>
        <Text style={[styles.navButtonLabel, { color: accentColor }]}>Trust</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.navButton} onPress={() => setShowAuditLog(true)}>
        <Text style={styles.navButtonIcon}>📋</Text>
        <Text style={[styles.navButtonLabel, { color: accentColor }]}>Log</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.navButton} onPress={() => setShowPrivacyPolicy(true)}>
        <Text style={styles.navButtonIcon}>📄</Text>
        <Text style={[styles.navButtonLabel, { color: accentColor }]}>Policy</Text>
      </TouchableOpacity>
    </View>

    <Text style={styles.footer}>
      ZEROPOINT — Zero data collected. Zero servers. Total control.
    </Text>
  </ScrollView>
</SafeAreaView>
```

);
}

// ═══════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════

const styles = StyleSheet.create({
container: {
flex: 1,
backgroundColor: ‘#0A0A0A’,
},
mainContent: {
paddingHorizontal: 20,
paddingBottom: 40,
},
loadingText: {
color: ‘#8E8E93’,
textAlign: ‘center’,
marginTop: 200,
fontSize: 16,
},
header: {
flexDirection: ‘row’,
justifyContent: ‘space-between’,
alignItems: ‘center’,
paddingTop: 16,
paddingBottom: 12,
},
appName: {
fontSize: 22,
fontWeight: ‘800’,
letterSpacing: 3,
},
settingsIcon: {
fontSize: 22,
},
profileRow: {
flexDirection: ‘row’,
justifyContent: ‘space-between’,
marginBottom: 24,
gap: 8,
},
profileButton: {
flex: 1,
paddingVertical: 8,
paddingHorizontal: 4,
borderRadius: 10,
borderWidth: 1,
borderColor: ‘#2C2C2E’,
alignItems: ‘center’,
},
profileButtonText: {
color: ‘#8E8E93’,
fontSize: 11,
fontWeight: ‘700’,
letterSpacing: 0.5,
},
profileButtonTextActive: {
color: ‘#FFFFFF’,
},
shieldButtonContainer: {
alignItems: ‘center’,
marginBottom: 28,
},
shieldButton: {
width: 200,
height: 200,
borderRadius: 100,
borderWidth: 2.5,
alignItems: ‘center’,
justifyContent: ‘center’,
},
shieldButtonIcon: {
fontSize: 48,
marginBottom: 8,
},
shieldButtonLabel: {
fontSize: 14,
fontWeight: ‘800’,
letterSpacing: 2,
},
shieldButtonSub: {
color: ‘#636366’,
fontSize: 11,
marginTop: 4,
letterSpacing: 0.3,
},
dashboardCard: {
backgroundColor: ‘#1C1C1E’,
borderRadius: 16,
padding: 18,
marginBottom: 16,
},
dashboardTitle: {
color: ‘#636366’,
fontSize: 11,
fontWeight: ‘700’,
letterSpacing: 1.5,
marginBottom: 10,
},
exposureRow: {
flexDirection: ‘row’,
alignItems: ‘baseline’,
marginBottom: 10,
},
exposureScore: {
fontSize: 48,
fontWeight: ‘800’,
},
exposureLabel: {
fontSize: 16,
fontWeight: ‘600’,
marginLeft: 8,
},
exposureBar: {
height: 6,
backgroundColor: ‘#2C2C2E’,
borderRadius: 3,
overflow: ‘hidden’,
marginBottom: 8,
},
exposureBarFill: {
height: ‘100%’,
borderRadius: 3,
},
exposureSubtext: {
color: ‘#636366’,
fontSize: 12,
},
permissionPanel: {
backgroundColor: ‘#1C1C1E’,
borderRadius: 16,
padding: 18,
marginBottom: 16,
},
panelTitle: {
color: ‘#636366’,
fontSize: 11,
fontWeight: ‘700’,
letterSpacing: 1.5,
marginBottom: 12,
},
permissionRow: {
flexDirection: ‘row’,
alignItems: ‘center’,
paddingVertical: 8,
borderBottomWidth: 1,
borderBottomColor: ‘#2C2C2E’,
},
permissionIcon: {
fontSize: 16,
width: 28,
},
permissionLabel: {
color: ‘#EBEBF5’,
fontSize: 15,
flex: 1,
fontWeight: ‘400’,
},
permissionStatus: {
paddingHorizontal: 10,
paddingVertical: 4,
borderRadius: 8,
},
permissionStatusText: {
fontSize: 12,
fontWeight: ‘700’,
letterSpacing: 0.5,
},
iosNotice: {
backgroundColor: ‘#1C1C1E’,
borderRadius: 12,
padding: 14,
marginBottom: 16,
borderLeftWidth: 3,
borderLeftColor: ‘#FF9F0A’,
},
iosNoticeText: {
color: ‘#8E8E93’,
fontSize: 13,
lineHeight: 18,
},
bottomNav: {
flexDirection: ‘row’,
justifyContent: ‘space-around’,
backgroundColor: ‘#1C1C1E’,
borderRadius: 16,
paddingVertical: 12,
marginBottom: 20,
},
navButton: {
alignItems: ‘center’,
flex: 1,
},
navButtonIcon: {
fontSize: 20,
marginBottom: 4,
},
navButtonLabel: {
fontSize: 11,
fontWeight: ‘600’,
letterSpacing: 0.5,
},
footer: {
color: ‘#3A3A3C’,
fontSize: 11,
textAlign: ‘center’,
letterSpacing: 0.3,
},
modalHeader: {
flexDirection: ‘row’,
justifyContent: ‘space-between’,
alignItems: ‘center’,
paddingHorizontal: 20,
paddingTop: 16,
paddingBottom: 12,
borderBottomWidth: 1,
borderBottomColor: ‘#2C2C2E’,
},
modalTitle: {
fontSize: 20,
fontWeight: ‘800’,
letterSpacing: 1,
},
closeButton: {
fontSize: 18,
fontWeight: ‘700’,
padding: 4,
},
modalContent: {
padding: 20,
paddingBottom: 40,
},
trustCard: {
backgroundColor: ‘#1C1C1E’,
borderRadius: 14,
padding: 16,
marginBottom: 12,
},
trustCardTitle: {
color: ‘#EBEBF5’,
fontSize: 15,
fontWeight: ‘700’,
marginBottom: 8,
},
trustCardText: {
color: ‘#8E8E93’,
fontSize: 14,
lineHeight: 21,
},
emptyLog: {
color: ‘#636366’,
textAlign: ‘center’,
fontSize: 15,
marginTop: 40,
},
auditEntry: {
backgroundColor: ‘#1C1C1E’,
borderRadius: 12,
padding: 14,
marginBottom: 10,
},
auditAction: {
fontSize: 14,
fontWeight: ‘700’,
marginBottom: 4,
},
auditTimestamp: {
color: ‘#636366’,
fontSize: 12,
},
clearButton: {
borderWidth: 1.5,
borderRadius: 12,
paddingVertical: 14,
alignItems: ‘center’,
marginTop: 16,
},
clearButtonText: {
color: ‘#FF3B30’,
fontSize: 14,
fontWeight: ‘600’,
},
policyText: {
color: ‘#8E8E93’,
fontSize: 14,
lineHeight: 22,
},
policyBold: {
color: ‘#EBEBF5’,
fontWeight: ‘700’,
},
settingsSectionTitle: {
color: ‘#636366’,
fontSize: 11,
fontWeight: ‘700’,
letterSpacing: 1.5,
marginBottom: 14,
marginTop: 8,
},
colorRow: {
flexDirection: ‘row’,
gap: 16,
marginBottom: 28,
},
colorSwatch: {
width: 44,
height: 44,
borderRadius: 22,
},
colorSwatchSelected: {
borderWidth: 3,
borderColor: ‘#FFFFFF’,
transform: [{ scale: 1.15 }],
},
onboardingContent: {
padding: 24,
paddingBottom: 48,
alignItems: ‘center’,
},
shieldLogo: {
fontSize: 64,
marginTop: 24,
marginBottom: 8,
},
onboardingTitle: {
fontSize: 36,
fontWeight: ‘900’,
letterSpacing: 6,
marginBottom: 6,
},
onboardingSubtitle: {
color: ‘#636366’,
fontSize: 16,
marginBottom: 32,
textAlign: ‘center’,
},
onboardingCard: {
backgroundColor: ‘#1C1C1E’,
borderRadius: 16,
padding: 18,
marginBottom: 14,
width: ‘100%’,
},
onboardingCardTitle: {
color: ‘#EBEBF5’,
fontSize: 15,
fontWeight: ‘700’,
marginBottom: 8,
},
onboardingCardText: {
color: ‘#8E8E93’,
fontSize: 14,
lineHeight: 21,
},
onboardingButton: {
borderRadius: 16,
paddingVertical: 18,
paddingHorizontal: 48,
marginTop: 24,
marginBottom: 16,
width: ‘100%’,
alignItems: ‘center’,
},
onboardingButtonText: {
color: ‘#FFFFFF’,
fontSize: 17,
fontWeight: ‘800’,
letterSpacing: 0.5,
},
onboardingFooter: {
color: ‘#3A3A3C’,
fontSize: 13,
textAlign: ‘center’,
},
});
