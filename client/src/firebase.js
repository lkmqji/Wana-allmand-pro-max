import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, deleteUser, setPersistence, browserLocalPersistence, updateProfile } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyDvF3qkvFl-4PlfWyUZhyQC10_DKGrYo7A",
  authDomain: "wana-allmand-pro-max.firebaseapp.com",
  projectId: "wana-allmand-pro-max",
  storageBucket: "wana-allmand-pro-max.firebasestorage.app",
  messagingSenderId: "181570626367",
  appId: "1:181570626367:web:ea9a481c91238aaebe698a",
  measurementId: "G-ZMT7ZEJVW7"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
setPersistence(auth, browserLocalPersistence).catch(console.error);
export const googleProvider = new GoogleAuthProvider();

export const loginWithGoogle = () => signInWithPopup(auth, googleProvider);
export const logout = () => signOut(auth);
export const deleteAccount = (user) => deleteUser(user);
export const updateUserProfile = (user, profile) => updateProfile(user, profile);

