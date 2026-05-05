class AppStrings {
  static String get tempContentHTML =>
      '''<div style="display: flex; justify-content: flex-start;">
  <div style="display: flex; flex-direction: column; gap: 4px; max-width: 260px;">
    <div style="background: #262626; border-radius: 18px 18px 18px 4px; padding: 12px 16px; display: flex; align-items: center; gap: 10px;">
      <div style="width: 32px; height: 32px; border-radius: 50%; border: 1.5px solid #555; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#aaa" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
      </div>
      <div>
        <p style="margin: 0; font-size: 13px; color: #000; font-weight: 500;">Temporary file shared</p>
        <p style="margin: 2px 0 0; font-size: 11px; color: #888;">Opened · No longer available</p>
      </div>
    </div>
  </div>
</div>''';
}
