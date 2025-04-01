            -- [...] Inside Tab:CreateSection function

            local SectionContent = CreateElement("Frame", {
                Name = "Content",
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40), -- Position remains the same
                Size = UDim2.new(1, 0, 1, -40) -- Adjust size to fill remaining space correctly
                -- AutomaticSize is mocked in the demo environment
            })

            local SectionPadding = CreateElement("UIPadding", {
                Parent = SectionContent,
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                -- V V V V V V V V V V V V V V V V V V V V V --
                -- ADDED PADDING TOP HERE TO CREATE SPACE --
                PaddingTop = UDim.new(10, 50) -- <<<<< CHANGE THIS LINE (was 0 before)
                -- ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ --
            })

            local SectionLayout = CreateElement("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, sectionInfo.ContentPadding)
            })

            -- Update SectionContainer size based on content (needed if not using AutomaticSize)
            local function UpdateSectionContainerSize()
                local contentHeight = SectionLayout.AbsoluteContentSize.Y + SectionPadding.PaddingTop.Offset + SectionPadding.PaddingBottom.Offset
                SectionContainer.Size = UDim2.new(1, 0, 0, 40 + contentHeight) -- 40 for title + content height
                UpdateCanvasSize() -- Update the parent tab's canvas size too
            end

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionContainerSize)
            -- Also update when children are added/removed (more robust)
            SectionContent.ChildAdded:Connect(UpdateSectionContainerSize)
            SectionContent.ChildRemoved:Connect(UpdateSectionContainerSize)


            -- Section Methods
            local Section = {}

            -- [...] Rest of the Section methods (AddButton, AddToggle, etc.)
