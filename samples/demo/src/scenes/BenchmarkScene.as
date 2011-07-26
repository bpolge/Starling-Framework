package scenes
{
    import starling.display.Button;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.EnterFrameEvent;
    import starling.events.Event;
    import starling.text.TextField;
    import starling.utils.formatString;

    public class BenchmarkScene extends Scene
    {
        private var mStartButton:Button;
        private var mResultText:TextField;
        
        private var mContainer:Sprite;
        private var mFrameCount:int;
        private var mElapsed:Number;
        private var mStarted:Boolean;
        private var mFailCount:int;
        private var mWaitFrames:int;
        
        public function BenchmarkScene()
        {
            super();
            
            // the container will hold all test objects
            mContainer = new Sprite();
            mContainer.touchable = false; // we do not need touch events on the test objects -- 
                                          // thus, it is more efficient to disable them.
            addChildAt(mContainer, 0);
            
            mStartButton = new Button(Assets.getTexture("ButtonNormal"), "Start benchmark");
            mStartButton.addEventListener(Event.TRIGGERED, onStartButtonTriggered);
            mStartButton.x = Constants.CenterX - int(mStartButton.width / 2);
            mStartButton.y = 20;
            addChild(mStartButton);
            
            mStarted = false;
            mElapsed = 0.0;
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        public override function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            mStartButton.removeEventListener(Event.TRIGGERED, onStartButtonTriggered);
            super.dispose();
        }
        
        private function onEnterFrame(event:EnterFrameEvent):void
        {
            if (!mStarted) return;
            
            mElapsed += event.passedTime;
            mFrameCount++;
            
            if (mFrameCount % mWaitFrames == 0)
            {
                var fps:Number = mWaitFrames / mElapsed;
                
                if (Math.ceil(fps) >= Constants.FPS)
                {
                    mFailCount = 0;
                    addTestObject();
                }
                else
                {
                    mFailCount++;
                    
                    if (mFailCount > 10)
                        mWaitFrames = 15; // slow down creation process to be more exact 
                    if (mFailCount == 14)
                        benchmarkComplete(); // target fps not reached for a while
                }
                
                mElapsed = mFrameCount = 0;
            }
            
            for (var i:int=0; i<mContainer.numChildren; ++i)
                mContainer.getChildAt(i).rotation += Math.PI / 2 * event.passedTime;
        }
        
        private function onStartButtonTriggered(event:Event):void
        {
            trace("Starting benchmark");
            
            mStartButton.visible = false;
            mStarted = true;
            mFailCount = 0;
            mWaitFrames = 3;
            mFrameCount = 0;
            
            if (mResultText) 
            {
                mResultText.removeFromParent(true);
                mResultText = null;
            }
            
            addTestObject();
        }
        
        private function addTestObject():void
        {
            var padding:int = 15;
            var egg:Image = new Image(Assets.getTexture("BenchmarkObject"));
            egg.x = padding + Math.random() * (Constants.GameWidth - 2 * padding);
            egg.y = padding + Math.random() * (Constants.GameHeight - 2 * padding);
            mContainer.addChild(egg);
        }
        
        private function benchmarkComplete():void
        {
            mStarted = false;
            mStartButton.visible = true;
            
            trace("Benchmark complete!");
            trace("FPS: " + Constants.FPS);
            trace("Number of objects: " + mContainer.numChildren);
            
            var resultString:String = formatString("Result:\n{0} objects\nwith {1} fps",
                                                   mContainer.numChildren, Constants.FPS);
            mResultText = new TextField(240, 200, resultString);
            mResultText.fontSize = 30;
            mResultText.x = Constants.CenterX - mResultText.width / 2;
            mResultText.y = Constants.CenterY - mResultText.height / 2;
            
            addChild(mResultText);
            
            mContainer.removeAllChildren();
        }
        
        
    }
}