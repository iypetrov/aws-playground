package main

import (
	"context"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/ip812/foo/config"
	"github.com/ip812/foo/logger"
)

func Handler(ctx context.Context, event interface{}) (interface{}, error) {
	log := logger.Get(ctx)
	log.Info("Event: %v", event)
	return event, nil
}

func main() {
	ctx := context.Background()
	cfg := config.New()
	log := logger.New(cfg)
	ctx = log.Inject(ctx)
	ctx = config.Inject(ctx, *cfg)

	lambda.StartWithOptions(Handler, lambda.WithContext(ctx))
}
