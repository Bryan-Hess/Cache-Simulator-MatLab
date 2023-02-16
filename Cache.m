classdef(ConstructOnLoad=true)Cache<handle   
    properties
        LayerSize
        Latency
        BlockSize
        Associativity
        WritePolicy
        writeType
        ValidArray
        ValidBits
        Tag
        DirtyBits
        LRU
        LRUArray
        TotalHits
        TotalMisses
        TotalAccess
        HitRate
        MissRate
    end
    
    methods
        function this = Cache(LayerSize, Latency, BlockSize, Associativity, WritePolicy)
            this.LayerSize = LayerSize;
            this.Latency = Latency;
            this.BlockSize = BlockSize;
            this.Associativity = Associativity;
            this.WritePolicy = WritePolicy;

            if WritePolicy == 1
                this.writeType = @wbwa;
            elseif WritePolicy == 2
                this.writeType = @wtnwa;
            else
                fprintf("Did Not Enter Valid Write Policy")
            end

            this.HitRate = 0;
            this.MissRate = 0;
            this.TotalHits = 0;
            this.TotalMisses = 0;
            this.TotalAccess = 0;
            this.ValidArray = false([LayerSize/BlockSize Associativity]);
            this.ValidBits= false([LayerSize/BlockSize 1]);
            this.Tag = zeros([LayerSize/BlockSize Associativity]);
            this.DirtyBits = false([LayerSize/BlockSize Associativity]);
            this.LRU = zeros([LayerSize/BlockSize 1]);%%USE THIS TO DISP LRU
            this.LRUArray = ones([LayerSize/BlockSize Associativity]) * Associativity;
        end
        

        %% READ FUNCTION
        function [res, evict, tagForEvicted, MissOrHit] = read(this, tag, SetIndex)
            %Searches Tag in LRU Array
            tags = this.Tag(SetIndex,:);
            index = find(tags == tag);
            hit = size(index,2);
                      
            evict = 0;
            tagForEvicted = 0;
            MissOrHit = [];
            
            %MISS
            if hit == 0
                MissOrHit = ['MISS:'];

                % Determine if an eviction needs to take place
                % Find LRUArray block
                LRUArray_index = find(this.LRUArray(SetIndex, :) == this.Associativity);

                %Eviction Check
                if this.ValidArray(SetIndex, LRUArray_index(1)) == true
                    evict = 1;
                    tagForEvicted = this.Tag(SetIndex, LRUArray_index(1));
                end
                this.Tag(SetIndex, LRUArray_index(1)) = tag;
                index = LRUArray_index(1);
                res = 0;
            %HIT    
            else
                MissOrHit = ['HIT:'];
                LRUArray_index = find(this.LRUArray(SetIndex,:) == this.Associativity);
                res = 1;
            end
            
            %LRUArray Update
            update_LRUArray = find(this.LRUArray(SetIndex,:) ~= this.Associativity);
            this.LRU(SetIndex) = this.LRUArray(SetIndex, LRUArray_index(1));%%USE THIS TO DISP LRU
            this.LRUArray(SetIndex, update_LRUArray) = this.LRUArray(SetIndex, update_LRUArray) + 1;
            this.LRUArray(SetIndex, LRUArray_index(1)) = 1;
            
            %Valibate Bit and BLock
            this.ValidArray(SetIndex,index) = 1;
            this.ValidBits(SetIndex) = 1;

            %HIT/MISS RATE RECALC
            if hit == 1
                this.TotalHits = this.TotalHits + 1;
                this.TotalAccess = this.TotalAccess + 1;
            else
                this.TotalMisses = this.TotalMisses + 1;
                this.TotalAccess = this.TotalAccess + 1;
            end
            this.HitRate = this.TotalHits/this.TotalAccess;
            this.MissRate = this.TotalMisses/this.TotalAccess;

        end
        
        %% CALLS ONE OF TWO WRITE FUNCTIONS
        function [res, evict, tagForEvicted, MissOrHit] = write(this, tag, SetIndex)
            [res, evict, tagForEvicted, MissOrHit] = this.writeType(this, tag, SetIndex);
        end
        
        %% Write-Back+Write-Allocate
        function [res, evict, tagForEvicted, MissOrHit] = wbwa(this,tag,SetIndex)
            %Searches Tag in LRU Array
            tags = this.Tag(SetIndex,:);
            index = find(tags == tag);
            hit = size(index, 2);
            
            evict = 0;
            tagForEvicted = 0;
            MissOrHit = []; 
            
            %MISS
            if hit == 0
                MissOrHit = ['MISS:'];
                LRUArray_index = find(this.LRUArray(SetIndex,:) == this.Associativity);
                if this.DirtyBits(SetIndex, LRUArray_index(1)) == true
%fprintf("Dirty Block")
                    evict = 1;
                    tagForEvicted = this.Tag(SetIndex, LRUArray_index(1));
                end
                this.Tag(SetIndex,LRUArray_index(1)) = tag;
                index = LRUArray_index(1);
                res = 0;
            %HIT
            else
                MissOrHit = ['HIT:'];
                this.Tag(SetIndex,index) = tag;
                LRUArray_index = find(this.LRUArray(SetIndex,:) == this.Associativity);
                res = 1;
            end
            
            %LRUArray Update
            update_LRUArray = find(this.LRUArray(SetIndex,:) ~= this.Associativity);
            this.LRUArray(SetIndex,update_LRUArray) = this.LRUArray(SetIndex,update_LRUArray) + 1;
            this.LRU(SetIndex) = this.LRUArray(SetIndex,LRUArray_index(1));%%USE THIS TO DISP LRU
            this.LRUArray(SetIndex,LRUArray_index(1)) = 1;
            this.ValidArray(SetIndex,index) = true;
            this.ValidBits(SetIndex) = true;
            this.DirtyBits(SetIndex,index) = true;

            %HIT/MISS RATE RECALC
            if hit == 1
                this.TotalHits = this.TotalHits + 1;
                this.TotalAccess = this.TotalAccess + 1;
            else
                this.TotalMisses = this.TotalMisses + 1;
                this.TotalAccess = this.TotalAccess + 1;
            end
            this.HitRate = this.TotalHits/this.TotalAccess;
            this.MissRate = this.TotalMisses/this.TotalAccess;
        end

        %% Write-Through+Non-Write_Allocate
        function [res, evict, tagForEvicted, MissOrHit] = wtnwa(this,tag,SetIndex)
            %Searches Tag in LRU Array
            tags = this.Tag(SetIndex,:);
            index = find(tags == tag);
            hit = size(index,2);
            
            evict = 0;
            tagForEvicted = 0;
            MissOrHit = [];
            
            %MISS
            if hit == 0
                MissOrHit = ['MISS:'];
                LRUArray_index = find(this.LRUArray(SetIndex,:) == this.Associativity);
                index = LRUArray_index(1);
                res = 0;
                
            %HIT    
            else
                MissOrHit = ['HIT:'];
                this.Tag(SetIndex,index) = tag;
                res = 1;
            end
            
            %LRUArray Update
            update_LRUArray = find(this.LRUArray(SetIndex,:) ~= this.Associativity);
            this.LRUArray(SetIndex,update_LRUArray) = this.LRUArray(SetIndex,update_LRUArray) + 1;
            LRUArray_index = find(this.LRUArray(SetIndex,:) == this.Associativity);
            this.LRU(SetIndex) = this.LRUArray(SetIndex, LRUArray_index(1));%%USE THIS TO DISP LRU
            this.LRUArray(SetIndex,index) = 1;

            %HIT/MISS RATE RECALC
            if hit == 1
                this.TotalHits = this.TotalHits + 1;
                this.TotalAccess = this.TotalAccess + 1;
            else
                this.TotalMisses = this.TotalMisses + 1;
                this.TotalAccess = this.TotalAccess + 1;
            end
            this.HitRate = this.TotalHits/this.TotalAccess;
            this.MissRate = this.TotalMisses/this.TotalAccess;
        end
        
        
    end
end

