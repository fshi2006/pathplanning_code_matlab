%function AStarFind()
    obstlist = [0,0;1 3;2 2;5,5]; % �ϰ�������λ�ã����赥λ����
    gres = 0.2; % դ��ߴ�Ϊ0.2��
    [minx,miny,obmap] = CalcObstMap(obstlist,gres); % minx miny��ʵ�ǵ�ͼ��
    
    % ��׺��i������դ�����꣬����i������ʵ������ 
    goal = [2.5,3.5];
    start_i = [4,3];
    col = goal(1); % ʵ��������դ������ת����x������������
    row = goal(2); % y����������
    col = ceil((col-minx)/gres); % ��goalת��Ϊդ�����꣬��������Ϊ����
    row = ceil((row-miny)/gres);
    goal_i = [row,col];
    start = (start_i - 0.5)*gres+[minx,miny]; % ��start_iդ������ת��Ϊʵ������
    
    [Grids, cost] = AStarSearch(start_i,goal_i,obmap); % ���������㷨
    
    % ��������·��
    pointIndex = goal_i;
    pathPoints = []; % �������·��
    while any(pointIndex~=start_i) % ���ݵ���ʼդ���ʱ���ҵ�����·��
        pathPoints(end+1,:) = (pointIndex-0.5)*gres+[minx,miny]; % ��դ�����ת��Ϊʵ�ʾ��룬������д������vector��push_back,Ҳ����д��pathPoints=[pathPoints;xxxxx],ע����ǰ�����Ҫ�����������������ôʹ��
        xi = Grids(pointIndex(1),pointIndex(2),1); % pointIndex�ĸ��ڵ��������
        yi = Grids(pointIndex(1),pointIndex(2),2); % pointIndex�ĸ��ڵ��������
        pointIndex = [xi, yi]; % ԭ��pointIndex�ĸ��ڵ�դ������
    end
    pathPoints(end+1,:) = (pointIndex-0.5)*gres+[minx,miny]; % ����ʼդ������·����
    
    % ��ͼ
    draw(minx,miny,gres,obmap,start,goal,obstlist,pathPoints);
    disp(['cost is ',num2str(cost)]);
%end
function draw(minx,miny,gres,obmap,start,goal,obstlist,pathPoints)
    hold on;
    grid on
    xlabel('x/m');
    ylabel('y/m');
    set(gca,'xaxislocation','top','yaxislocation','left','ydir','reverse') % % �����Ͻ�Ϊԭ�㽨������ϵ
    % �����ϰ�դ���ͼ��ʵ�����겻���޸ģ�դ��������Ҫ��ת��
    for i = 1:size(obmap,1) % ע���ڻ�ͼ��ʱ��դ���ͼ�е�����i����ʵ�ʵ�ͼ�е�y��������������Ҫ��Ӧ�޸�
        for j = 1:size(obmap,2)
            if obmap(i,j) == 1
                rectangle('Position',[[minx,miny]+([j,i]-1)*gres,gres,gres],'FaceColor',[0 .1 .1]) % rectangle('Position',pos)��os ָ��Ϊ [x y w h] ��ʽ����Ԫ�������������ݵ�λ��ʾ��.x �� y Ԫ��ȷ��λ�ã�w �� h Ԫ��ȷ��դ��Ŀ�Ⱥ͸߶�.
            else
                rectangle('Position',[[minx,miny]+([j,i]-1)*gres,gres,gres],'FaceColor',[1  1  1]) % ���Ƶ�ʱ���Ǵ�0��ʼ���Ƶ�
            end
        end
    end
    % ע���ڻ�ͼ��ʱ��դ���ͼ�е�����i����ʵ�ʵ�ͼ�е�y��������������Ҫ��Ӧ�޸�    
    plot(goal(1),goal(2),'ro'); % goal��ʵ�����겻���޸�
    plot(start(2),start(1),'*'); % start��դ���ͼ���꣬դ���ͼ�е�����i����ʵ�ʵ�ͼ�е�y
    for i = 1:size(obstlist,1)
        plot(obstlist(i,1),obstlist(i,2),'bo');
    end

    plot(pathPoints(:,2),pathPoints(:,1)); 
end
function [minx,miny,obmap] = CalcObstMap(obstlist,gres) % ʹ���ϰ����е�������С���깹����ͼ
    minx = min(obstlist(:,1));
    maxx = max(obstlist(:,1));
    miny = min(obstlist(:,2));
    maxy = max(obstlist(:,2));
    xwidth = maxx - minx; % �������
    xwidth = ceil(xwidth/gres); % ����դ��������������뵽����
    ywidth = maxy - miny;
    ywidth = ceil(ywidth/gres);
    obmap = zeros(ywidth,xwidth); % ��ʼ��դ���ͼ��ֵȫΪ0
    for i = 1:ywidth
        for j = 1:xwidth
            ix = minx+(j-1/2)*gres; % ����ɢդ��ת��Ϊʵ��λ�����꣬��λ����
            iy = miny+(i-1/2)*gres;
            [~,D] = knnsearch(obstlist,[ix,iy]); %�����(ix, iy)����obstlist�е������һ����ľ���
            if D < 0.5 % ����С��0.5����Ϊ���ϰ����һ���֣��ϰ���ı߳�����״Ϊ������
                obmap(i,j) = 1;
            end
        end
    end
end
function [Grids, cost] = AStarSearch(start,goal,obmap)
    dim = size(obmap); % ����դ���ͼ�ߴ磬����m*n��m�У�n��
    Grids = zeros(dim(1),dim(2),4); 
    for i = 1:dim(1)
        for j = 1:dim(2)
            Grids(i,j,1) = i; % դ���ͼ�е�(i,j)�ĸ��ڵ��դ��������
            Grids(i,j,2) = j; % դ���ͼ�е�(i,j)�ĸ��ڵ��դ��������
            Grids(i,j,3) = norm(([i,j]-goal)); % ����դ�������ֵh
            Grids(i,j,4) = inf; % ����ʼ�㵽��ǰ��i,j�߹��ľ��룬ʵ�ʾ���gֵ
        end
    end
    Open = start; % Open���ϣ���Ŵ���չ��դ��ڵ㣬����ʵ������
    Grids(start(1),start(2),4) = 0; % ����ʼ�㵽�õ�ľ���
    Close = []; % Close���ϣ������չ����դ��ڵ㣬����ʵ������
    while ~isempty(Open)% ��openΪ��ʱ��������ϣ�ΪA*���������������������1.�ҳ���С�ĵ� 2.��չ�� 3.�ѵ����close������
        [wknode,Open] = PopOpen(Open,Grids); % �ҳ�����ֵf��С�ĵ�wknode��f=g+h��Ȼ���Open��ɾ���õ�
        [Grids,Open,Close,target_flag] = Update(wknode,goal,obmap,Grids,Open,Close); % ��չ�õ�wknode
        Close(end+1,:) = wknode; %#ok<AGROW> �Ѹõ�wknode����close������
        if target_flag % �����ɹ�
            break
        end
    end
    cost = Grids(goal(1),goal(2),3) + Grids(goal(1),goal(2),4); % f=g+h��goal��������ֵΪ0������Grids(goal(1),goal(2),3)=0,���ܴ����Ҳ���·�������
end

function [Grids,Open,Close,target_flag] = Update(wknode,goal,obmap,Grids,Open,Close)
    dim = size(obmap); % �к�����Ŀ��m*n
    target_flag=0; % ����������·����
    for i = -1:1 % i,j����8���˶���ʽ���������ң����ϣ����ϣ����£�����
        for j = -1:1
            adjnode = wknode+[i,j]; % ���ݲ�ͬ�˶���ʽ�����ڽ�դ��������
            row = adjnode(1);
            col = adjnode(2);
            if i == 0 && j == 0 % ��������
                continue
            elseif row < 1 || row > dim(1) % ����������Խ��
                continue
            elseif col < 1 || col > dim(2) % ����������Խ��
                continue
            elseif obmap(row,col) == 1 % �������ϰ����դ��
                continue
            elseif ~isempty(Close) && ismember(adjnode,Close,'rows') % ������Close�����е�դ��
                continue
            end
            fcost = Grids(wknode(1),wknode(2),4)+norm([i,j]); %���㵱ǰ�㵽�ڽ�դ����fֵ��f=g+h
            if Grids(row,col,4) > fcost % �ڽ�դ���ľ�fֵ����fֵ�󣬸���fֵ
                Grids(row,col,1) = wknode(1); % �����ڽ�դ���ĸ��ڵ�������
                Grids(row,col,2) = wknode(2); % �����ڽ�դ���ĸ��ڵ�������
                Grids(row,col,4) = fcost; % ������դ����fֵ
                % ����ڽ�դ��㲻���ڲ���դ���Ҳ����Ŀ���
                if ~ismember(adjnode,Open,'rows')
                    if ~isequal(adjnode,goal)
                        Open(end+1,:) = adjnode; %#ok<AGROW
                    else
                        Open(end+1,:) = adjnode; %#ok<AGROW
                        target_flag=1;
                        return
                    end
                end
            end
        end
    end
end

function [wknode,Open] = PopOpen(Open,Grids)
    mincost = inf; % ��¼��С��fֵ
    minidx = 1; % ��Сfֵ��դ�������
    for i = 1:size(Open,1) % �ҳ���Сfֵ��դ��㣬size(Open,1)��Open�����е����Ŀ��Open��һ�����У�2�еľ���
        node = Open(i,:); % ȡ����i��դ��ڵ��դ������
        fcost = Grids(node(1),node(2),3)+Grids(node(1),node(2),4); % ���㵱ǰդ���Ĺ���ֵf=g+h
        if fcost < mincost % ����Сfֵ��դ��ڵ�
            minidx = i;
            mincost = fcost;
        end
    end
    wknode = Open(minidx,:); %ȡ������
    Open(minidx,:) = []; % ɾ����դ��㣬�����դ���ǰ��
end
