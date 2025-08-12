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
            title: "Using AI Driven Applications to Optimize Agent Productivity",
            desc: "Build powerful AI Agents and automations with no code.",
            isNew: true,
            onClick: chatWithAgent,
            image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=500&h=300&fit=crop&crop=center",
            buttonText: "Start Agent Chat"
        },
        {
            title: "Agent Flow Solution for Global Automation Networks",
            desc: "Create custom workflows and automations with visual flow builder.",
            isNew: false,
            onClick: buildAgentFlow,
            image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=500&h=300&fit=crop&crop=center",
            buttonText: "Build Flow"
        },
        {
            title: "A Command Driven Approach to Optimizing Slash Performance",
            desc: "Save time and inject prompts using custom slash commands.",
            isNew: false,
            onClick: createSlashCommand,
            image: "https://images.unsplash.com/photo-1629904853893-c2c8981a1dc5?w=500&h=300&fit=crop&crop=center",
            buttonText: "Create Command"
        },
        {
            title: "Hub Discovery Platform for Community Content",
            desc: "Discover and share community-created slash commands and prompts.",
            isNew: false,
            onClick: exploreHub,
            image: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500&h=300&fit=crop&crop=center",
            buttonText: "Explore Hub"
        },
        {
            title: "System Prompt Customization for AI Reply Enhancement",
            desc: "Modify the system prompt to customize the AI replies of a workspace.",
            isNew: true,
            onClick: modifySystemPrompt,
            image: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=500&h=300&fit=crop&crop=center",
            buttonText: "Modify Prompt"
        },
        {
            title: "Dynamic Variable Management for Prompt Optimization",
            desc: "Create and manage dynamic variables for your custom prompts.",
            isNew: false,
            onClick: managePromptVariables,
            image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&h=300&fit=crop&crop=center",
            buttonText: "Manage Variables"
        }
    ];

    const itemsPerPage = 3;
    const totalSlides = Math.ceil(features.length / itemsPerPage);

    const nextSlide = () => {
        setCurrentSlide((prev) => (prev + 1) % totalSlides);
    };

    const prevSlide = () => {
        setCurrentSlide((prev) => (prev - 1 + totalSlides) % totalSlides);
    };

    const getCurrentFeatures = () => {
        const startIndex = currentSlide * itemsPerPage;
        return features.slice(startIndex, startIndex + itemsPerPage);
    };

    return (
        <div className="mt-8 p-8 rounded-lg bg-white">
            <h2 className="text-gray-900 text-xl font-bold mb-6">Explore more features</h2>
            <div className="relative">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {getCurrentFeatures().map((feature, index) => (
                        <div
                            key={index}
                            className="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-200"
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
                                    <span className="text-blue-600 text-sm font-medium">Case Study</span>
                                    {feature.isNew && (
                                        <span className="bg-green-500 text-white text-xs px-2 py-1 rounded-full">New</span>
                                    )}
                                </div>
                                <h3 className="text-gray-900 font-bold text-lg mb-3 leading-tight">
                                    {feature.title}
                                </h3>
                                <p className="text-gray-600 text-sm mb-4 leading-relaxed">
                                    {feature.desc}
                                </p>
                                <button className="w-full border-2 border-blue-600 text-blue-600 py-2 px-4 rounded hover:bg-blue-600 hover:text-white transition-all duration-200 font-medium">
                                    {feature.buttonText}
                                </button>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Navigation Buttons */}
                {totalSlides > 1 && (
                    <>
                        <button
                            onClick={prevSlide}
                            className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-4 w-10 h-10 bg-blue-600 rounded-full shadow-lg flex items-center justify-center hover:bg-blue-700 transition-all duration-200 text-white"
                        >
                            ←
                        </button>
                        <button
                            onClick={nextSlide}
                            className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-4 w-10 h-10 bg-blue-600 rounded-full shadow-lg flex items-center justify-center hover:bg-blue-700 transition-all duration-200 text-white"
                        >
                            →
                        </button>
                    </>
                )}

                {/* Slide Indicators */}
                {totalSlides > 1 && (
                    <div className="flex justify-center mt-6 gap-2">
                        {Array.from({ length: totalSlides }).map((_, index) => (
                            <button
                                key={index}
                                onClick={() => setCurrentSlide(index)}
                                className={`w-3 h-3 rounded-full transition-all duration-200 ${index === currentSlide
                                        ? 'bg-blue-600'
                                        : 'bg-gray-300 hover:bg-gray-400'
                                    }`}
                            />
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}