function daily_return = BackTest(back_handle, model, pltfm, begin_date, end_date)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    Mkt_tradedays = pltfm.Mkt_tradedays;
    ret = pltfm.Return;
    ret(isnan(ret)) = 0;
    gap = back_handle.day;
    cost = model.GetCost();
    universe = model.GetUniverse();
    
    begin_index = find(Mkt_tradedays >= begin_date);
    begin_index = begin_index(1);
    end_index = find(Mkt_tradedays <= end_date);
    end_index = end_index(end);
    trade_day_count = end_index - begin_index + 1;
    
    dPosWeight = zeros(trade_day_count, length(pltfm.TickersCell));
    rtnArr = zeros(trade_day_count, 4);
    %�����һ��ĳֲ�
    [out_1, out_2] = model.ModelPort(pltfm, begin_date);
    pos = cell2mat(out_1( :, 3));
    dPosWeight(1, :) = pos';
    rtnArr(1, 1) = 0 - cost * sum(pos);
    rtnArr(1, 2) = sum(pos);
    rtnArr(1, 3) = cost * sum(pos);
    rtnArr(1, 4) = 0;
    count = 1;
    
    for index = (begin_index + 1):(end_index)
        count = count + 1;
        date = Mkt_tradedays(index);
        %����ǰһ������
        if sum(dPosWeight(count-1, :)) > 0.0001
            %��ǰһ���гֲ֣���������
            dPosWeight(count, :) = dPosWeight(count-1, :) .* ret(count, :);
            rtnArr(count, 1) = sum(dPosWeight(count, :)) - 1;
            rtnArr(count, 2) = 0;
            rtnArr(count, 3) = 0;
            rtnArr(count, 4) = sum(dPosWeight(count, :)) - 1;
            %�������³ֲ�
            dPosWeight(count, :) = dPosWeight(count, :)./sum(dPosWeight(count, :));
        else
            %��ǰһ��û�гֲ�
            dPosWeight(count, :) = 0;
            rtnArr(count, 1) = 0;
            rtnArr(count, 2) = 0;
            rtnArr(count, 3) = 0;
            rtnArr(count, 4) = 0;
        end
        %����ǻ����գ���������ϲ�����
        if mod(count, gap) == 1
            %�����²�λ
            [out_1, out_2] = model.ModelPort(pltfm, begin_date);
            pos = cell2mat(out_1( :, 3));
            pos = pos';
            if sum(dPosWeight(count, :)) == 0
                tmp = pos;
            else
                tmp = pos - dPosWeight(count, :)/(sum(dPosWeight(count, :));
            end
            turnover = sum(abs(tmp));
            rtnArr(count, 2) = turnover;
            rtnArr(count, 3) = turnover * cost;
            rtnArr(count, 1) = (rtnArr(count, 1) + 1) * (1 - turnover * cost) - 1;
            if all(pos(count, :) == 0)
                dPosWeight(count, :) = 0;
            else
                dPosWeight(count, :) = pos ./ sum(pos);
            end
        end
    end
    
end
