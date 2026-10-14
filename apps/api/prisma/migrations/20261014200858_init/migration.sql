-- CreateEnum
CREATE TYPE "VehicleType" AS ENUM ('CAR', 'MOTORCYCLE');

-- CreateEnum
CREATE TYPE "SpotStatus" AS ENUM ('FREE', 'OCCUPIED', 'MAINTENANCE');

-- CreateEnum
CREATE TYPE "TicketStatus" AS ENUM ('OPEN', 'PAID', 'CANCELED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('PIX', 'CREDIT_CARD', 'DEBIT_CARD', 'CASH');

-- CreateTable
CREATE TABLE "spots" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "type" "VehicleType" NOT NULL,
    "status" "SpotStatus" NOT NULL DEFAULT 'FREE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "spots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vehicles" (
    "id" TEXT NOT NULL,
    "plate" TEXT NOT NULL,
    "type" "VehicleType" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vehicles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pricing_rules" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "vehicleType" "VehicleType" NOT NULL,
    "toleranceMinutes" INTEGER NOT NULL DEFAULT 15,
    "firstPeriodMinutes" INTEGER NOT NULL DEFAULT 60,
    "firstPeriodPrice" DECIMAL(10,2) NOT NULL,
    "additionalPeriodMinutes" INTEGER NOT NULL DEFAULT 60,
    "additionalPeriodPrice" DECIMAL(10,2) NOT NULL,
    "dailyMaxPrice" DECIMAL(10,2),
    "validFrom" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "validUntil" TIMESTAMP(3),
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pricing_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tickets" (
    "id" TEXT NOT NULL,
    "number" SERIAL NOT NULL,
    "vehicleId" TEXT NOT NULL,
    "spotId" TEXT NOT NULL,
    "pricingRuleId" TEXT,
    "entryAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "exitAt" TIMESTAMP(3),
    "amount" DECIMAL(10,2),
    "status" "TicketStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" TEXT NOT NULL,
    "ticketId" TEXT NOT NULL,
    "method" "PaymentMethod" NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    "paidAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customers" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "document" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "monthly_plans" (
    "id" TEXT NOT NULL,
    "customerId" TEXT NOT NULL,
    "vehicleId" TEXT NOT NULL,
    "spotId" TEXT,
    "price" DECIMAL(10,2) NOT NULL,
    "weekDays" INTEGER[],
    "startTime" TEXT,
    "endTime" TEXT,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3),
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "monthly_plans_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "spots_code_key" ON "spots"("code");

-- CreateIndex
CREATE INDEX "spots_type_status_idx" ON "spots"("type", "status");

-- CreateIndex
CREATE UNIQUE INDEX "vehicles_plate_key" ON "vehicles"("plate");

-- CreateIndex
CREATE INDEX "pricing_rules_vehicleType_active_idx" ON "pricing_rules"("vehicleType", "active");

-- CreateIndex
CREATE UNIQUE INDEX "tickets_number_key" ON "tickets"("number");

-- CreateIndex
CREATE INDEX "tickets_vehicleId_status_idx" ON "tickets"("vehicleId", "status");

-- CreateIndex
CREATE INDEX "tickets_spotId_status_idx" ON "tickets"("spotId", "status");

-- CreateIndex
CREATE INDEX "tickets_entryAt_idx" ON "tickets"("entryAt");

-- CreateIndex
CREATE UNIQUE INDEX "payments_ticketId_key" ON "payments"("ticketId");

-- CreateIndex
CREATE UNIQUE INDEX "customers_document_key" ON "customers"("document");

-- CreateIndex
CREATE INDEX "monthly_plans_customerId_idx" ON "monthly_plans"("customerId");

-- CreateIndex
CREATE INDEX "monthly_plans_vehicleId_active_idx" ON "monthly_plans"("vehicleId", "active");

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "vehicles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_spotId_fkey" FOREIGN KEY ("spotId") REFERENCES "spots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_pricingRuleId_fkey" FOREIGN KEY ("pricingRuleId") REFERENCES "pricing_rules"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monthly_plans" ADD CONSTRAINT "monthly_plans_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monthly_plans" ADD CONSTRAINT "monthly_plans_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "vehicles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "monthly_plans" ADD CONSTRAINT "monthly_plans_spotId_fkey" FOREIGN KEY ("spotId") REFERENCES "spots"("id") ON DELETE SET NULL ON UPDATE CASCADE;
