import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import paths from "@/utils/paths";
import Workspace from "@/models/workspace";

export default function LatestProjects() {
    const navigate = useNavigate();
    const [currentSlide, setCurrentSlide] = useState(0);

    const chatWithAgent = async () => {
        const workspaces = await Workspace.all();
        if (workspaces.length > 0) {
            const firstWorkspace = workspaces[0];
            navigate(paths.workspace.chat(firstWorkspace.slug, { search: { action: "set-agent-chat" } }));
        }
    };

    const buildAgentFlow = () => navigate(paths.agents.builder());
    const createSlashCommand = async () => {
        const workspaces = await Workspace.all();
        if (workspaces.length > 0) {
            const firstWorkspace = workspaces[0];
            navigate(paths.workspace.chat(firstWorkspace.slug, { search: { action: "open-new-slash-command-modal" } }));
        }
    };
    const exploreHub = () => window.open(paths.communityHub.viewMoreOfType("slash-commands"), "_blank");
    const modifySystemPrompt = async () => {
        const workspaces = await Workspace.all();
        if (workspaces.length > 0) {
            const firstWorkspace = workspaces[0];
            navigate(paths.workspace.settings.chatSettings(firstWorkspace.slug, { search: { action: "focus-system-prompt" } }));
        }
    };
    const managePromptVariables = () => navigate(paths.settings.systemPromptVariables());

    const features = [
        {
            title: "AI & Document Chat",
            desc: "Start conversations with intelligent AI agents that can help with various tasks and provide automated assistance.",
            isNew: true,
            onClick: chatWithAgent,
            image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=500&h=300&fit=crop&crop=center",
            buttonText: "Start Agent Chat"
        },
        {
            title: "AI Agent",
            desc: "Design and create custom AI agent workflows using an intuitive drag-and-drop interface for complex automations.",
            isNew: false,
            onClick: buildAgentFlow,
            image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=500&h=300&fit=crop&crop=center",
            buttonText: "Build Flow"
        },
        
        
        {
            title: "AI Prompt",
            desc: "Customize how your AI agents respond by modifying system prompts to match your specific use cases and requirements.",
            isNew: true,
            onClick: modifySystemPrompt,
            image: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=500&h=300&fit=crop&crop=center",
            buttonText: "Modify Prompt"
        },
        {
            title: "Prompt Manager",
            desc: "Define and manage dynamic variables that can be used across your AI prompts for consistent and flexible interactions.",
            isNew: false,
            onClick: managePromptVariables,
            image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&h=300&fit=crop&crop=center",
            buttonText: "Manage Variables"
        },
        {
            title: "Custom Slash Commands",
            desc: "Create personalized slash commands to quickly execute common tasks and streamline your AI interactions.",
            isNew: false,
            onClick: createSlashCommand,
            image: "https://images.unsplash.com/photo-1629904853893-c2c8981a1dc5?w=500&h=300&fit=crop&crop=center",
            buttonText: "Create Command"
        },
        {
            title: "Community Hub Explorer",
            desc: "Browse and discover community-created AI tools, prompts, and automation templates shared by other users.",
            isNew: false,
            onClick: exploreHub,
            image: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500&h=300&fit=crop&crop=center",
            buttonText: "Explore Hub"
        },
    ];

    return (
        <div className="mt-8 p-8 rounded-lg" style={{ backgroundColor: '#00213A' }}>
            <h2 className="text-white text-xl font-bold mb-6">Explore more features</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {features.map((feature, index) => (
                        <div
                            key={index}
                            className="rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-600"
                            style={{ backgroundColor: '#003A5C' }}
                            onClick={feature.onClick}
                        >
                            <div className="h-48 w-full relative overflow-hidden">
                                <img
                                    src={feature.image}
                                    alt={feature.title}
                                    className="w-full h-full object-cover"
                                />
                                <div className="absolute inset-0 bg-black bg-opacity-20"></div>
                            </div>
                            <div className="p-6">
                                <div className="flex items-center justify-between mb-3">
                                    <span className="text-cyan-400 text-sm font-medium">Aditi AI</span>
                                    {feature.isNew && (
                                        <span className="bg-cyan-500 text-white text-xs px-2 py-1 rounded-full">New</span>
                                    )}
                                </div>
                                <h3 className="text-white font-bold text-lg mb-3 leading-tight">
                                    {feature.title}
                                </h3>
                                <p className="text-gray-300 text-sm mb-4 leading-relaxed">
                                    {feature.desc}
                                </p>
                                <button
                                    className="w-full border-2 text-white py-2 px-4 rounded hover:text-white transition-all duration-200 font-medium"
                                    style={{
                                        borderColor: '#4DD0E1',
                                        backgroundColor: 'transparent'
                                    }}
                                    onMouseEnter={(e) => e.target.style.backgroundColor = '#4DD0E1'}
                                    onMouseLeave={(e) => e.target.style.backgroundColor = 'transparent'}
                                >
                                    {feature.buttonText}
                                </button>
                            </div>
                        </div>
                    ))}
            </div>
        </div>
    );
}