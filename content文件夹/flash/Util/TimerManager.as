package Util
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    /**
     *这是一个timer的管理类,创建这个类的想法来自我接触as3不久的时候的一次思考
     * 其时我觉得as3的管理很不自动化,主要表现在内存管理方面,在这方面又以timer的管理最为麻烦
     * 当我们创建一个大型的as程序时,会在不为人知的地方创建大量的timer,我们大多时候会注意回收这些timer,而总有疏漏的时候
     * 于是我想到将所有的timer都放在一起管理,这种做法我在很多大型开源项目中看到了被使用的痕迹,但是没有看到过一个归纳性的用法
     *
     * ******通过使用这个类,我们可以节省很多资源,所有频率相同的timer都将统一成一个timer来管理,这样可以节约很多性能,当然也可以定义不同频率的timer,但是在这里鼓励统一频率
     * 这样可以只需要一个timer就完成所有的循环工作,然后当使用这个管理类的时候不要担心会丢失常用的timer功能,例如你想在达到某个条件停止物体的循环运动的时候,
     * 你可以在添加的时候加一个限制函数,甚至比普通的用法更简单
     *
     * ******这个类同时提供一些其他的有用功能,其中尤为重要的是可以在任何时刻调用输出信息函数,可以查看当前使用了几个timer,以及每个timer的频率和绑定的函数列表,这样可以方便
     * 地在调试的时候查看信息
     *
     * ******这个类的使用非常简单,如果你不想了解其内部机制,则只需要在想添加一个timer的时候,使用一句TimerManager.add(..)就可以了,如果定时器没有启动,则调用此函数后将立即启动
     * 当满足了停止的条件或者手动移除了所有的函数列表的时候timer将自动停止,不用担心在不需要循环的时候会占用额外的cpu时间
     *
     * ******你可以在添加每个函数的时候添加一个限制函数,这个限制函数必须有返回值,如果返回值是false,则循环将一直进行下去,如果某个循环中限制函数的返回值为true,则停止此循环
     *
     *
     * @author 小haha
     *
     */
    public class TimerManager
    {
        /**
         *默认的timer的间隔,50帧每秒
         */
        static public var timerInterval:int=20;
        /**
         *定时器列表,格式为timerList.T20:Timer.之所以如此结构是为了方便多个timer的取出和赋值,方便管理大量的timer对象
         */
        static public var timerList:Object=new Object();
        /**
         *函数列表,结构跟定时器列表类似,为functionList.T1:Array,里面包含了某个定时器的所有要执行的函数引用
         */
        static private var functionList:Object=new Object();
        /**
         *循环函数,每个间隔的Timer都有一个循环执行的函数, functionList.T1:Function
         */
        static private var funcList:Object=new Object(); 

        static private var limitFuncList:Object=new Object();
        /**
         *向管理器添加一个要定时执行的函数,如果没有指定第二个参数,则将以默认的频率执行此函数,默认为50帧每秒
         *执行此函数后,将自动开启timer,而无需手动开启,当满足条件后将根据条件移除某个函数,当函数列表为空时,
         * 将停止timer,节省资源,第三个参数必须有返回值,当返回值为true的时候,将停止此绑定函数的循环
         * @param func 要添加的函数
         * @param timerInter 执行此函数的周期
         * @param limitFunc 绑定的限制函数,当满足此函数(==true)时,将停止此循环,即移除此函数,如果要再满足条件时执行其他函数,请在第一个参数
         * 函数中书写,无需特殊绑定
         * @return
         *
         */ 

        static public function  add(func:Function,timerInter=null,limitFunc=null):void
        { 

            if(timerInter==null){
                timerInter=TimerManager.timerInterval;
            }
            if(limitFunc==null){
                limitFunc=function (){
                    return false;
                }
            }
            var ii:String="T"+timerInter;
            if(timerList[ii]==undefined){
                //如果还没有定义这个间隔的timer,则定义之
                timerList[ii]=new Timer(timerInter);
            }
            //向某个定时器添加一个要定时执行的函数
            if(functionList[ii]==undefined){
                functionList[ii]=new Array();
                functionList[ii].push(func); 

                limitFuncList[ii]=new Array();
                limitFuncList[ii].push(limitFunc);
            }else{
                functionList[ii].push(func);
                limitFuncList[ii].push(limitFunc);
            } 

            if(funcList[ii]==undefined){
                //定义某个定时器循环函数
                funcList[ii]=function(){
                    //满足条件时,移除此函数,停止对其的循环
                    try{
                    for(var i=0;i<limitFuncList[ii].length;i++){
                        trace(limitFuncList[ii][i]());
                        if(limitFuncList[ii][i]()==true){
                         TimerManager.removeFunc(functionList[ii][i],timerInter); 

                    }
                    } 

                    }catch(e:Error){}
                    var length=functionList[ii].length;
                    if(length==0){
                        timerList[ii].stop();
                    }
                    //      trace(length)
                    for(var i=0;i<functionList[ii].length;i++){
                        //执行所有的函数
                        //      trace(functionList[ii])
                        functionList[ii][i]();
                    }
                }
                    timerList[ii].addEventListener(TimerEvent.TIMER,funcList[ii]);
            } 

            if(timerList[ii].running==false){
                //如果当前定时器没有运行则运行之
                timerList[ii].start();
            } 

        }
        /**
         *从某个频率的timer函数列表里移除某函数
         * @param func
         * @param timerInter
         *
         */
        static public function removeFunc(func:Function,timerInter=null):void
        {
            if(timerInter==null){
                timerInter=TimerManager.timerInterval;
            }
            var ii:String="T"+timerInter;
            //搜索数组,如果发现的确有此func,则删除之,否则不做任何处理,也不抛出任何错误
            var index:int=functionList[ii].indexOf(func);
            if(index>=0){
                //存在此函数
                functionList[ii].splice(index,1);
                limitFuncList[ii].splice(index,1);
                //  trace(functionList[ii]);
            }
        }
        /**
         *在调试中输出当前所有定时器的详细信息
         * @return
         *
         */
        static public function  traceInfo()
        {
            trace("当前运行的计时器如下:")
            for(var timer in timerList){
                trace("timer-"+timer+":   时间间隔:"+timerList[timer].delay+"  已运行次数:"+timerList[timer].currentCount+"  运行状态:"+timerList[timer].running); 

                trace("                     当前timer执行的函数列表如下:");
                for(var e in functionList[timer]){
                    trace("                                "+e+":"+getFunctionName(functionList[timer][e]));
                }
            }
        }
        /**
         *获取函数名,输入一个函数对象,将获取到此函数的函数名,用于输出信息
         * @param fun
         * @param useParameter
         * @return
         *
         */
        static public function getFunctionName(fun:Function):String {
            var funName:String = ""; 

            try { 

                fun(fun, fun, fun, fun, fun);
                fun();
            }catch(err:Error) {
                funName = err.message.toString().replace(/.+\#|\(\).*|.+: /g, "");
            }
            if(funName==""){
                return "只能获取类层次的函数名,无法获取局部函数名";
            }
                    return funName;
        }
        static public function pauseTimer(timerInterval=null):void
        {
            if(timerInterval==null){
                for(var i in timerList){
                    timerList[i].stop();
                }
            }
        }
        static public function resumeTimer(timerInterval=null):void
        {
            if(timerInterval==null){
                for(var i in timerList){
                    timerList[i].start();
                }
            }
        }
    }
}