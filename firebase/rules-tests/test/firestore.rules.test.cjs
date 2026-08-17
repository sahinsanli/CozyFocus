const fs = require('node:fs');
const path = require('node:path');
const {
  after,
  before,
  beforeEach,
  describe,
  it,
} = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  Timestamp,
  doc,
  getDoc,
  setDoc,
} = require('firebase/firestore');

const projectId = 'cozy-focus-rules-test';
let testEnv;

function validProgress() {
  return {
    progress: {
      schemaVersion: 3,
      username: 'Test User',
      profileAvatarId: 'moonleaf',
      settings: {
        darkMode: true,
        focusReminders: true,
        autoStartBreaks: false,
        dailyGoalMinutes: 120,
        defaultFocusMinutes: 25,
        shortBreakMinutes: 5,
        sleepTimerMinutes: 30,
      },
      dailyMinutes: {},
      selectedDecorationIds: [],
      decorationPositions: {},
      craftProgress: {},
      inventory: {},
      pendingRewards: [],
      roomPlacements: {},
      badges: {},
      dailyReward: {},
    },
    updatedAt: Timestamp.now(),
  };
}

describe('Cozy Focus Firestore rules', () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: fs.readFileSync(
          path.resolve(__dirname, '../../../firestore.rules'),
          'utf8',
        ),
      },
    });
  });

  beforeEach(async () => testEnv.clearFirestore());
  after(async () => testEnv.cleanup());

  it('allows an authenticated user to write only their valid profile', async () => {
    const uid = 'owner';
    const db = testEnv.authenticatedContext(uid).firestore();
    await assertSucceeds(
      setDoc(doc(db, `users/${uid}`), {
        uid,
        email: 'owner@example.com',
        isAnonymous: false,
        providers: ['password'],
        updatedAt: Timestamp.now(),
      }),
    );
    await assertFails(
      setDoc(doc(db, `users/${uid}`), {
        uid: 'another-user',
        email: null,
        isAnonymous: true,
        providers: [],
        updatedAt: Timestamp.now(),
      }),
    );
  });

  it('rejects unauthenticated and cross-user access', async () => {
    const ownerDb = testEnv.authenticatedContext('owner').firestore();
    const attackerDb = testEnv.authenticatedContext('attacker').firestore();
    const guestDb = testEnv.unauthenticatedContext().firestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await setDoc(doc(adminDb, 'users/owner/state/progress'),
        validProgress(),
      );
    });
    await assertSucceeds(getDoc(doc(ownerDb, 'users/owner/state/progress')));
    await assertFails(getDoc(doc(attackerDb, 'users/owner/state/progress')));
    await assertFails(getDoc(doc(guestDb, 'users/owner/state/progress')));
  });

  it('accepts the app progress schema and rejects unexpected fields', async () => {
    const db = testEnv.authenticatedContext('owner').firestore();
    await assertSucceeds(
      setDoc(doc(db, 'users/owner/state/progress'), validProgress()),
    );
    const invalid = validProgress();
    invalid.progress.settings.testMode = true;
    await assertFails(
      setDoc(doc(db, 'users/owner/state/progress'), invalid),
    );
  });

  it('validates idempotent focus session documents', async () => {
    const db = testEnv.authenticatedContext('owner').firestore();
    const session = doc(db, 'users/owner/focusSessions/focus-1');
    await assertSucceeds(
      setDoc(session, {
        minutes: 25,
        completedAt: Timestamp.now(),
        createdAt: Timestamp.now(),
      }),
    );
    await assertFails(
      setDoc(doc(db, 'users/owner/focusSessions/focus-invalid'), {
        minutes: 0,
        completedAt: Timestamp.now(),
        createdAt: Timestamp.now(),
      }),
    );
  });
});
