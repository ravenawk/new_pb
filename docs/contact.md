# Get in Touch

I'd love to hear from you!

Whether you spot an error in a post, have a question about something I've written, or just want to share your own homelab adventures, I'd love to hear from you.

<form name="contact" method="POST" data-netlify="true" style="max-width: 600px; margin-top: 2rem;">
  <div style="margin-bottom: 1rem;">
    <label for="name" style="display: block; margin-bottom: 0.5rem; font-weight: bold;">Name:</label>
    <input type="text" id="name" name="name" required style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;">
  </div>
  <div style="margin-bottom: 1rem;">
    <label for="email" style="display: block; margin-bottom: 0.5rem; font-weight: bold;">Email:</label>
    <input type="email" id="email" name="email" required style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;">
  </div>
  <div style="margin-bottom: 1rem;">
    <label for="subject" style="display: block; margin-bottom: 0.5rem; font-weight: bold;">Subject:</label>
    <select id="subject" name="subject" style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px;">
      <option value="general">General question</option>
      <option value="error">Found an error</option>
      <option value="suggestion">Have a suggestion</option>
      <option value="homelab">Homelab discussion</option>
      <option value="infrastructure">Infrastructure/Ansible chat</option>
    </select>
  </div>
  <div style="margin-bottom: 1rem;">
    <label for="message" style="display: block; margin-bottom: 0.5rem; font-weight: bold;">Message:</label>
    <textarea id="message" name="message" rows="5" required style="width: 100%; padding: 0.5rem; border: 1px solid #ddd; border-radius: 4px; resize: vertical;"></textarea>
  </div>
  <!-- Netlify bot protection -->
  <div style="display: none;">
    <input name="bot-field" />
  </div>
  <button type="submit" style="background: #0066cc; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem;">
    Send Message
  </button>
</form>


__Response time:__ *I try to respond within a few days, but sometimes the homelab demands immediate attention. 😉*

__Privacy note:__ This form is handled by Netlify and only collects what you provide above. No tracking, no nonsense.
