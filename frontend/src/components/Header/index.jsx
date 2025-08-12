import React from "react";
import { useNavigate } from "react-router-dom";

export default function Header() {
    const navigate = useNavigate();

    const handleLogoClick = () => {
        navigate('/');
    };
    return (
        <header className="w-full shadow-lg" style={{ backgroundColor: '#22d3ee' }}>
            <div className="max-w-full px-6">
                <div className="flex items-center justify-between h-20">
                    {/* Logo and Brand */}
                    <div className="flex items-center ml-12">
                        <div className="flex-shrink-0 cursor-pointer" onClick={handleLogoClick}>
                            <img
                                src="https://www.aditiconsulting.com/hubfs/aditi-logo-blue.svg"
                                alt="Aditi Consulting Logo"
                                className="h-12 w-auto hover:opacity-80 transition-opacity duration-200"
                            />
                        </div>
                        {/* <div className="ml-4">
                            <h1 className="text-slate-800 text-2xl font-bold tracking-wider">
                                CONSULTING
                            </h1>
                        </div> */}
                    </div>

                    {/* Right side - Navigation/Menu */}
                    <div className="flex items-center space-x-6 mr-8">
                  
                        {/* Navigation menu items */}
                        <nav className="hidden md:flex space-x-6">
                            <button
                                onClick={() => navigate('/')}
                                className="text-white hover:text-gray-200 font-medium transition-colors duration-200"
                            >
                                Home
                            </button>
                            <button
                                onClick={() => navigate('/settings/agents')}
                                className="text-white hover:text-gray-200 font-medium transition-colors duration-200"
                            >
                                AI Agents
                            </button>
                            <button
                                onClick={() => navigate('/settings/workspace-chats')}
                                className="text-white hover:text-gray-200 font-medium transition-colors duration-200"
                            >
                                Workspaces
                            </button>
                            <button
                                onClick={() => navigate('/settings/llm-preference')}
                                className="text-white hover:text-gray-200 font-medium transition-colors duration-200"
                            >
                                Settings
                            </button>
                        </nav>

                        {/* Mobile menu button */}
                        <div className="md:hidden">
                            <button className="text-slate-800 hover:text-slate-600 focus:outline-none">
                                <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            {/* Decorative bottom gradient */}
            <div className="h-1 bg-gradient-to-r from-cyan-300 via-cyan-400 to-cyan-500"></div>
        </header>
    );
}