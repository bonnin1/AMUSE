function d = mirdesign(orig,argin,option,postoption,specif,type); %,nout)

if isa(orig,'mirdesign')
    d.method = orig.method;
    d.argin = orig.argin;
    d.option = orig.option;
    d.postoption = orig.postoption;
    d.specif = orig.specif;
    d.type = orig.type;
    d.frame = orig.frame;
    d.segment = orig.segment;
    d.chunkdecomposed = orig.chunkdecomposed;
    d.size = orig.size;
    d.file = orig.file;
    d.sampling = orig.sampling;
    d.nochunk = orig.nochunk;
    d.ascending = orig.ascending;
    d.overlap = orig.overlap;
    d.chunk = orig.chunk;
    d.eval = orig.eval;
    d.interchunk = orig.interchunk;
    d.acrosschunks = orig.acrosschunks;
    d.ready = orig.ready;
    d.struct = orig.struct;
    d.stored = orig.stored;
    d.index = orig.index;
    d.tmpfile = orig.tmpfile;
    d.tmpof = orig.tmpof;
    %d.nout = orig.nout;
else
    d.method = orig;
    d.argin = argin;
    d.option = option;
    d.postoption = postoption;
    d.specif = specif;
    d.type = type;
    if ischar(argin)
        d.frame = {};
        d.segment = {};
        d.chunkdecomposed = 0;
        d.size = {};
        d.file = '';
        d.sampling = 0;
        d.nochunk = 0;
        if not(isempty(orig)) && ...
                strcmp(func2str(orig),'mirenvelope') && d.option.zp == 2
            %if ((isnan(d.option.zp) && strcmpi(option.filter,'IIR')) || ...
            %     (not(isnan(d.option.zp)) &&  d.option.zp)) 
            %    d.ascending = 1;
            %else
                d.ascending = 0;
            %end
        else
            d.ascending = 1;
        end
        d.overlap = 0;
    else
        if iscell(argin)
            argin = argin{1};
        end
        if (strcmp(func2str(orig),'mirspectrum') && d.option.alongbands) ...
            || (isfield(specif,'nochunk') && specif.nochunk)
            d.frame = [];
            if isfield(d.specif,'eachchunk')
                d.specif = rmfield(d.specif,'eachchunk');
                d.specif = rmfield(d.specif,'combinechunk');
            end
        else
            d.frame = argin.frame;
            if not(isempty(d.frame)) && ...
                isfield(d.specif,'framedchunk')% && ...
                %not(d.specif.framedchunk) %|| ...
                %(isfield(d.frame,'chunknow'))
                % Some frame-docomposed extractor should not be evaluated
                % chunk after chunk because the whole result is needed for
                % subsequent computations.
                    d.frame.chunknow = 0;
            end
        end
        d.segment = argin.segment;
        d.chunkdecomposed = argin.chunkdecomposed;
        d.size = argin.size;
        d.file = argin.file;
        d.sampling = argin.sampling;
        if (isfield(specif,'nochunk') && specif.nochunk) || not(isempty(argin.stored))
            d.nochunk = 2; % Flag to indicate that no chunk should be performed, because a temporary variable will be already computed.
        else
            d.nochunk = argin.nochunk;
        end
        if strcmp(func2str(orig),'mirenvelope')
            if d.option.zp == 2
                d.ascending = not(isempty(d.segment));
            else
                d.ascending = 1;
            end
        else
            d.ascending = argin.ascending;
        end
        d.overlap = argin.overlap;
    end
    d.chunk = [];
    d.eval = 0;
    d.interchunk = [];   % Data that can be passed between successive chunks during the main process.
    d.acrosschunks = []; % Data that can be accumulated among chunks during the beforechunk process.
    d.ready = 0;
    d.struct = [];
    d.stored = [];
    d.index = NaN;
    if not(isempty(orig)) && strcmp(func2str(orig),'mirenvelope') && ...
                d.option.zp == 2 && isempty(d.segment)
        % Triggers the use of temporary file for the mirenvelope computation
        d.tmpfile.fid = 0;
    else
        d.tmpfile = [];
    end
    d.tmpof = [];
    %if nargin < 7
    %    d.nout = 1;
    %else
    %    d.nout = nout;
    %end
end
d = class(d,'mirdesign');