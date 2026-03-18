import React from 'react';
import { useNavigate } from 'react-router-dom';
import '../App.css';

export default function PrivacyPolicy() {
  const navigate = useNavigate();

  return (
    <div className="legal-page">
      <nav className="nav">
        <a href="/" className="nav-logo">
          <img src="/apollo.png" alt="Apollo Logo" className="logo-img" />
        </a>
        <button className="nav-cta" onClick={() => navigate('/')}>Back Home</button>
      </nav>

      <div className="legal-content">
        <h1>Privacy Policy</h1>
        <p className="last-updated">Last updated: March 18, 2026</p>

        <section>
          <h2>1. Introduction</h2>
          <p>
            Apollo ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and otherwise handle your information when you use our website and services (collectively, the "Service").
          </p>
        </section>

        <section>
          <h2>2. Information We Collect</h2>
          <p>
            We collect information in various ways, including:
          </p>
          <h3>2.1 Information You Provide</h3>
          <ul>
            <li>Account registration information (email, username, password)</li>
            <li>Profile information (name, bio, niche, programming interests, skill level, goals)</li>
            <li>OAuth credentials from connected social platforms (GitHub, LinkedIn, Twitter/X, Google, Dev.to)</li>
            <li>Submissions and solutions to coding problems</li>
            <li>Messages and communications with other users</li>
            <li>Any other information you voluntarily provide</li>
          </ul>

          <h3>2.2 Information Automatically Collected</h3>
          <ul>
            <li>Device information (IP address, browser type, operating system)</li>
            <li>Usage data (pages visited, features used, time spent, interactions)</li>
            <li>Cookies and similar tracking technologies</li>
            <li>Location information (based on IP address)</li>
          </ul>

          <h3>2.3 Information from Third Parties</h3>
          <ul>
            <li>Data from OAuth providers (GitHub, LinkedIn, Twitter/X, Google, Dev.to)</li>
            <li>Public profiles and repositories from connected services</li>
          </ul>
        </section>

        <section>
          <h2>3. How We Use Your Information</h2>
          <p>
            We use the information we collect for various purposes:
          </p>
          <ul>
            <li>To create and maintain your account</li>
            <li>To provide and improve the Service</li>
            <li>To match you with rival developers based on skills and interests</li>
            <li>To calculate and display your XP, rank, and leaderboard position</li>
            <li>To verify your identity and prevent fraudulent activity</li>
            <li>To send you service notifications and updates</li>
            <li>To respond to your inquiries and customer support requests</li>
            <li>To analyze usage patterns and improve user experience</li>
            <li>To enforce our Terms of Service and other agreements</li>
            <li>To personalize content and recommendations</li>
            <li>For marketing and promotional purposes (with your consent)</li>
          </ul>
        </section>

        <section>
          <h2>4. How We Protect Your Information</h2>
          <p>
            We implement appropriate technical and organizational measures to protect your information from unauthorized access, alteration, disclosure, or destruction. These measures include:
          </p>
          <ul>
            <li>SSL/TLS encryption for data in transit</li>
            <li>Secure password hashing and storage</li>
            <li>Access controls and authentication mechanisms</li>
            <li>Regular security audits and updates</li>
            <li>Limited access to personal information by employees</li>
          </ul>
          <p>
            However, no method of transmission over the Internet or electronic storage is completely secure. While we strive to use commercially reasonable means to protect your personal information, we cannot guarantee its absolute security.
          </p>
        </section>

        <section>
          <h2>5. Information Sharing and Disclosure</h2>
          <p>
            We may share your information in the following circumstances:
          </p>
          <ul>
            <li><strong>Public Profile:</strong> Your username, rank, interests, and goals are visible to other users for rival matching purposes</li>
            <li><strong>Service Providers:</strong> We share information with third parties who provide services on our behalf (hosting, analytics, payment processing)</li>
            <li><strong>Legal Requirements:</strong> We may disclose information when required by law or to protect our rights, privacy, safety, or property</li>
            <li><strong>Business Transfers:</strong> In case of merger, acquisition, or bankruptcy, your information may be transferred as part of that transaction</li>
            <li><strong>With Your Consent:</strong> We may share information for other purposes with your explicit consent</li>
          </ul>
          <p>
            We do not sell your personal information to third parties.
          </p>
        </section>

        <section>
          <h2>6. Your Rights and Choices</h2>
          <p>
            Depending on your location, you may have certain rights regarding your information:
          </p>
          <ul>
            <li><strong>Access:</strong> You can request access to the personal information we hold about you</li>
            <li><strong>Correction:</strong> You can request that we correct inaccurate information</li>
            <li><strong>Deletion:</strong> You can request deletion of your account and associated data</li>
            <li><strong>Portability:</strong> You can request a copy of your data in a portable format</li>
            <li><strong>Opt-out:</strong> You can opt out of marketing communications and certain data collection</li>
          </ul>
          <p>
            To exercise these rights, please contact us at privacy@apollo.gg
          </p>
        </section>

        <section>
          <h2>7. Cookies and Tracking</h2>
          <p>
            We use cookies and similar tracking technologies to enhance your experience on the Service. These may include:
          </p>
          <ul>
            <li><strong>Essential Cookies:</strong> Required for authentication and core functionality</li>
            <li><strong>Analytics Cookies:</strong> Used to understand how users interact with the Service</li>
            <li><strong>Preference Cookies:</strong> Remember your settings and preferences</li>
          </ul>
          <p>
            You can control cookie settings through your browser. Disabling cookies may affect the functionality of the Service.
          </p>
        </section>

        <section>
          <h2>8. Third-Party Integrations</h2>
          <p>
            Apollo integrates with third-party services for authentication and profile verification:
          </p>
          <ul>
            <li><strong>GitHub:</strong> We access your public profile and repositories for verification</li>
            <li><strong>LinkedIn:</strong> We access your profile information for verification</li>
            <li><strong>Twitter/X:</strong> We access your profile information for verification</li>
            <li><strong>Google:</strong> We use Google OAuth for authentication</li>
            <li><strong>Dev.to:</strong> We access your Dev.to API key for profile verification</li>
          </ul>
          <p>
            Your use of these services is subject to their respective privacy policies and terms. We only store the minimum information necessary to verify your identity and associate your social profiles with your Apollo account.
          </p>
        </section>

        <section>
          <h2>9. Data Retention</h2>
          <p>
            We retain your personal information for as long as necessary to provide the Service and fulfill the purposes outlined in this policy. You can request deletion of your account at any time, though we may retain certain information as required by law or for legitimate business purposes.
          </p>
        </section>

        <section>
          <h2>10. Children's Privacy</h2>
          <p>
            The Service is not directed to anyone under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will delete such information and terminate the child's account.
          </p>
        </section>

        <section>
          <h2>11. International Data Transfers</h2>
          <p>
            Your information may be stored, processed, and transferred in countries other than your country of residence, which may have different data protection laws. By using the Service, you consent to such transfers.
          </p>
        </section>

        <section>
          <h2>12. Updates to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time to reflect changes in our practices or applicable laws. We will notify you of material changes by updating the "Last updated" date at the top of this policy. Your continued use of the Service following the posting of updated terms means you accept and agree to the changes.
          </p>
        </section>

        <section>
          <h2>13. Contact Us</h2>
          <p>
            If you have any questions about this Privacy Policy or our privacy practices, please contact us at:
          </p>
          <ul>
            <li>Email: privacy@apollo.gg</li>
            <li>Website: apollo.gg</li>
          </ul>
          <p>
            We will respond to your inquiry within 30 days.
          </p>
        </section>

        <section>
          <h2>14. California Residents</h2>
          <p>
            If you are a California resident, you have specific rights under the California Consumer Privacy Act (CCPA). You have the right to know what personal information is collected, used, shared, or sold; the right to delete personal information; and the right to opt-out of the sale or sharing of personal information. To exercise these rights, please contact us at privacy@apollo.gg
          </p>
        </section>

        <section>
          <h2>15. European Residents</h2>
          <p>
            If you are located in the European Union, you have rights under the General Data Protection Regulation (GDPR). These include the rights mentioned above, as well as the right to lodge a complaint with your local data protection authority.
          </p>
        </section>
      </div>

      <footer className="footer">
        <div className="footer-logo">
          <img src="/apolloBlack.png" alt="Apollo Logo" className="logo-img-footer" />
        </div>
        <div className="footer-note">© 2025 Apollo — Forge your legacy</div>
      </footer>
    </div>
  );
}
