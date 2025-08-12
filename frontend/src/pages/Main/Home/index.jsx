import React from "react";
import QuickLinks from "./QuickLinks";
import ExploreFeatures from "./ExploreFeatures";
import LatestProjects from "./LatestProjects";
import Checklist from "./Checklist";
import AditiBranding from "@/components/AditiBranding";
import { isMobile } from "react-device-detect";

export default function Home() {
  return (
    <div
      style={{ height: isMobile ? "100vh" : "calc(100vh - 80px)" }}
      className="relative md:ml-[2px] md:mr-[16px] md:my-[16px] md:rounded-[16px] bg-theme-bg-container w-full overflow-hidden"
    >
      <div className="w-full h-full flex flex-col items-center overflow-y-auto no-scroll">
        <div className="w-full max-w-[1200px] flex flex-col gap-y-[24px] p-4 pt-16 md:p-12 md:pt-11 pb-8">
          {/* <AditiBranding /> */}
          {/* <Checklist /> */}
          {/* <QuickLinks /> */}
          {/* <ExploreFeatures /> */}
          <LatestProjects />
        </div>
      </div>
    </div>
  );
}