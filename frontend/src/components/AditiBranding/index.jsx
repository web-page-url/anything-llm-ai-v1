import React from "react";

export default function AditiBranding() {
  return (
    <div className="w-full flex flex-col items-center justify-center mb-8 px-4">
      {/* Logo and Company Name */}
      <div className="flex flex-col sm:flex-row items-center gap-4 mb-6">
        {/* Aditi Consulting Logo */}
        <div className="w-20 h-20 sm:w-16 sm:h-16 flex items-center justify-center">
          <img
            src="/aditi-logo-2.0.png"
            alt="Aditi Consulting Logo"
            className="w-full h-full object-contain drop-shadow-lg"
          />
        </div>

        {/* Company Name and Tagline */}
        <div className="flex flex-col text-center sm:text-left">
          <h1 className="text-2xl sm:text-3xl font-bold text-theme-text-primary bg-gradient-to-r from-blue-600 to-blue-800 bg-clip-text text-transparent">
            Aditi Consulting
          </h1>
          <p className="text-sm text-theme-text-secondary font-medium mt-1">
            AI-Powered Knowledge Management
          </p>
        </div>
      </div>

      {/* Welcome Message */}
      <div className="text-center max-w-3xl">
        <h2 className="text-lg sm:text-xl font-semibold text-theme-text-primary mb-3">
          Welcome to Your Intelligent Document Assistant
        </h2>
        <p className="text-theme-text-secondary text-sm sm:text-base leading-relaxed mb-4">
          Transform your documents into intelligent conversations. Upload files, ask questions, and discover insights
          with our secure, private AI assistant designed specifically for Aditi Consulting's needs.
        </p>

        {/* Key Features */}
        {/* <div className="flex flex-wrap justify-center gap-4 text-xs sm:text-sm text-theme-text-secondary">
          <span className="bg-theme-bg-secondary px-3 py-1 rounded-full">🔒 Secure & Private</span>
          <span className="bg-theme-bg-secondary px-3 py-1 rounded-full">📄 Document Processing</span>
          <span className="bg-theme-bg-secondary px-3 py-1 rounded-full">🤖 AI-Powered Chat</span>
          <span className="bg-theme-bg-secondary px-3 py-1 rounded-full">⚡ Instant Insights</span>
        </div> */}
      </div>

      {/* Decorative Line */}
      <div className="w-24 h-1 bg-gradient-to-r from-blue-600 to-blue-800 rounded-full mt-6"></div>
    </div>
  );
}