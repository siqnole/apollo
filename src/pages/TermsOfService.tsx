import React from 'react';
import { useNavigate } from 'react-router-dom';
import '../App.css';

export default function TermsOfService() {
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
        <h1>Terms of Service</h1>
        <p className="last-updated">Last updated: March 18, 2026</p>

        <section>
          <h2>1. Acceptance of Terms</h2>
          <p>
            By accessing and using the Apollo platform ("Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.
          </p>
        </section>

        <section>
          <h2>2. Use License</h2>
          <p>
            Permission is granted to temporarily download one copy of the materials (information or software) on Apollo's Service for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
          </p>
          <ul>
            <li>Modifying or copying the materials</li>
            <li>Using the materials for any commercial purpose or for any public display</li>
            <li>Attempting to decompile, disassemble, reverse engineer any software contained on the Service</li>
            <li>Removing any copyright or other proprietary notations from the materials</li>
            <li>Transferring the materials to another person or "mirroring" the materials on any other server</li>
            <li>Violating any applicable laws or regulations</li>
            <li>Harassing, threatening, or intimidating other users</li>
            <li>Submitting false, fraudulent, or misleading information</li>
          </ul>
        </section>

        <section>
          <h2>3. Disclaimer</h2>
          <p>
            The materials on Apollo's Service are provided "as is". Apollo makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.
          </p>
        </section>

        <section>
          <h2>4. Limitations</h2>
          <p>
            In no event shall Apollo or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Apollo's Service, even if Apollo or Apollo's authorized representative has been notified orally or in writing of the possibility of such damage.
          </p>
        </section>

        <section>
          <h2>5. Accuracy of Materials</h2>
          <p>
            The materials appearing on Apollo's Service could include technical, typographical, or photographic errors. Apollo does not warrant that any of the materials on the Service are accurate, complete, or current. Apollo may make changes to the materials contained on the Service at any time without notice.
          </p>
        </section>

        <section>
          <h2>6. Materials and Content</h2>
          <p>
            Apollo has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Apollo of the site. Use of any such linked website is at the user's own risk.
          </p>
        </section>

        <section>
          <h2>7. Modifications</h2>
          <p>
            Apollo may revise these terms of service for the Service at any time without notice. By using the Service, you are agreeing to be bound by the then current version of these terms of service.
          </p>
        </section>

        <section>
          <h2>8. Governing Law</h2>
          <p>
            These terms and conditions are governed by and construed in accordance with the laws of the United States, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.
          </p>
        </section>

        <section>
          <h2>9. User Conduct</h2>
          <p>
            You agree not to use the Service:
          </p>
          <ul>
            <li>To transmit any unlawful, threatening, abusive, defamatory, obscene, or otherwise objectionable material</li>
            <li>To impersonate or attempt to impersonate any person or entity</li>
            <li>To post, transmit, or display any material that violates intellectual property rights</li>
            <li>To spam, flood, or otherwise interfere with the normal operation of the Service</li>
            <li>To collect or track personal information of others without consent</li>
            <li>To exploit or harm children in any way</li>
          </ul>
        </section>

        <section>
          <h2>10. Account Responsibility</h2>
          <p>
            You are responsible for maintaining the confidentiality of your account and password and for restricting access to your account. You agree to accept responsibility for all activities that occur under your account or password. Apollo reserves the right to refuse service or terminate accounts that violate these terms.
          </p>
        </section>

        <section>
          <h2>11. Intellectual Property Rights</h2>
          <p>
            The content, features, and functionality of the Service (including but not limited to all information, software, text, displays, images, video, and audio) are owned by Apollo, its licensors, or other providers of such material and are protected by copyright and other intellectual property laws.
          </p>
        </section>

        <section>
          <h2>12. Third-Party Integrations</h2>
          <p>
            Apollo integrates with third-party services (GitHub, LinkedIn, Twitter/X, Google, Dev.to) for authentication and profile verification. Your use of these services is subject to their respective terms of service and privacy policies. Apollo is not responsible for third-party services or their content.
          </p>
        </section>

        <section>
          <h2>13. Limitation of Liability</h2>
          <p>
            To the fullest extent permissible by law, Apollo shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, in connection with this agreement, the Service, or your use thereof.
          </p>
        </section>

        <section>
          <h2>14. Contact Us</h2>
          <p>
            If you have any questions about these Terms of Service, please contact us at support@apollo.gg
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
